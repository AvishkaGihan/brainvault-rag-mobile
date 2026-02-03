/**
 * Chat History Service
 * Story 5.8: Persist chat history per document
 */

import {
  FieldValue,
  Timestamp,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import { AppError, ValidationError } from "../types/api.types";
import type {
  ChatHistory,
  ChatHistoryMessage,
  ChatMessageRecord,
  ChatMessageRole,
  ChatSource,
} from "../types/chat.types";
import { logger } from "../utils/logger";

interface ChatHistoryDependencies {
  db?: Firestore;
}

interface AppendMessageInput {
  role: ChatMessageRole;
  content: string;
  sources?: ChatSource[];
}

export class ChatHistoryService {
  private readonly db: Firestore;
  private readonly maxMessages = 100;
  private readonly archivePageSize = 100;

  constructor(deps: ChatHistoryDependencies = {}) {
    this.db = deps.db ?? getFirestore();
  }

  async appendMessages(params: {
    userId: string;
    documentId: string;
    chatId: string;
    messages: AppendMessageInput[];
  }): Promise<void> {
    const { userId, documentId, chatId, messages } = params;

    this.assertAppendInput({ userId, documentId, chatId, messages });

    const docRef = this.db.collection("documents").doc(documentId);
    const chatRef = docRef.collection("chats").doc(chatId);
    const historyRef = chatRef.collection("history");

    await this.db.runTransaction(async (tx) => {
      const docSnap = await tx.get(docRef);
      const document = docSnap.data() as { userId?: string } | undefined;
      if (!docSnap.exists || !document?.userId || document.userId !== userId) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      const chatSnap = await tx.get(chatRef);
      const existingMessages =
        (chatSnap.data()?.messages as ChatMessageRecord[] | undefined) ?? [];

      const newMessages = messages.map((message) => ({
        role: message.role,
        content: message.content,
        sources: message.sources ?? [],
        timestamp: FieldValue.serverTimestamp(),
      }));

      const totalCount = existingMessages.length + newMessages.length;
      const overflow = Math.max(0, totalCount - this.maxMessages);

      let messagesToArchive: ChatMessageRecord[] = [];
      let remainingExisting = existingMessages;
      let remainingNew = newMessages;

      if (overflow > 0) {
        const archiveFromExistingCount = Math.min(
          existingMessages.length,
          overflow,
        );
        messagesToArchive = existingMessages.slice(0, archiveFromExistingCount);
        remainingExisting = existingMessages.slice(archiveFromExistingCount);

        const overflowRemaining = overflow - archiveFromExistingCount;
        if (overflowRemaining > 0) {
          messagesToArchive = messagesToArchive.concat(
            remainingNew.slice(0, overflowRemaining),
          );
          remainingNew = remainingNew.slice(overflowRemaining);
        }
      }

      const combinedMessages = [...remainingExisting, ...remainingNew];

      if (!chatSnap.exists) {
        tx.set(chatRef, {
          messages: combinedMessages,
          createdAt: FieldValue.serverTimestamp(),
          lastMessageAt: FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(chatRef, {
          messages: combinedMessages,
          lastMessageAt: FieldValue.serverTimestamp(),
        });
      }

      if (messagesToArchive.length > 0) {
        const pages = this.chunkMessages(
          messagesToArchive,
          this.archivePageSize,
        );
        pages.forEach((page) => {
          const pageRef = historyRef.doc();
          tx.set(pageRef, {
            messages: page,
            createdAt: FieldValue.serverTimestamp(),
          });
        });
      }
    });

    logger.info("Chat history persisted", {
      userId,
      documentId,
      chatId,
      messageCount: messages.length,
    });
  }

  async getRecentMessages(params: {
    userId: string;
    documentId: string;
    chatId: string;
    limit?: number;
  }): Promise<ChatHistory> {
    const { userId, documentId, chatId, limit = this.maxMessages } = params;
    this.assertListInput({ userId, documentId, chatId, limit });

    await this.assertDocumentOwnership({ userId, documentId });

    const chatSnap = await this.db
      .collection("documents")
      .doc(documentId)
      .collection("chats")
      .doc(chatId)
      .get();

    if (!chatSnap.exists) {
      return { chatId, messages: [] };
    }

    const storedMessages =
      (chatSnap.data()?.messages as ChatMessageRecord[] | undefined) ?? [];

    const recentMessages = storedMessages.slice(-limit);

    return {
      chatId,
      messages: recentMessages.map((message) =>
        this.toChatHistoryMessage(message),
      ),
    };
  }

  async getOlderMessages(params: {
    userId: string;
    documentId: string;
    chatId: string;
    before?: string;
    limit?: number;
  }): Promise<ChatHistory> {
    const {
      userId,
      documentId,
      chatId,
      before,
      limit = this.maxMessages,
    } = params;

    this.assertListInput({ userId, documentId, chatId, limit });

    await this.assertDocumentOwnership({ userId, documentId });

    const historyRef = this.db
      .collection("documents")
      .doc(documentId)
      .collection("chats")
      .doc(chatId)
      .collection("history");

    let query = historyRef.orderBy("createdAt", "desc");

    if (before) {
      const cursorDate = new Date(before);
      if (Number.isNaN(cursorDate.getTime())) {
        throw new ValidationError("Invalid before cursor", { before });
      }
      query = query.where("createdAt", "<", Timestamp.fromDate(cursorDate));
    }

    const pagesNeeded = Math.max(1, Math.ceil(limit / this.archivePageSize));
    const snapshot = await query.limit(pagesNeeded).get();

    const pages = snapshot.docs
      .map((doc) => doc.data())
      .sort(
        (a, b) =>
          this.toMillis(a.createdAt as unknown) -
          this.toMillis(b.createdAt as unknown),
      );

    const messages = pages.flatMap(
      (page) => (page.messages as ChatMessageRecord[] | undefined) ?? [],
    );

    const limitedMessages = messages.slice(0, limit);

    return {
      chatId,
      messages: limitedMessages.map((message) =>
        this.toChatHistoryMessage(message),
      ),
    };
  }

  private assertAppendInput(params: {
    userId: string;
    documentId: string;
    chatId: string;
    messages: AppendMessageInput[];
  }): void {
    const { userId, documentId, chatId, messages } = params;

    if (!userId || !documentId || !chatId) {
      throw new ValidationError("Missing identifiers", {
        userId,
        documentId,
        chatId,
      });
    }

    if (!Array.isArray(messages) || messages.length === 0) {
      throw new ValidationError("Messages are required", {
        messageCount: Array.isArray(messages) ? messages.length : 0,
      });
    }

    messages.forEach((message, index) => {
      if (!message.content || message.content.trim().length === 0) {
        throw new ValidationError("Message content is required", { index });
      }

      if (message.role !== "user" && message.role !== "assistant") {
        throw new ValidationError("Invalid message role", { index });
      }
    });
  }

  private assertListInput(params: {
    userId: string;
    documentId: string;
    chatId: string;
    limit: number;
  }): void {
    const { userId, documentId, chatId, limit } = params;

    if (!userId || !documentId || !chatId) {
      throw new ValidationError("Missing identifiers", {
        userId,
        documentId,
        chatId,
      });
    }

    if (!Number.isFinite(limit) || limit <= 0) {
      throw new ValidationError("Invalid limit", { limit });
    }
  }

  private async assertDocumentOwnership(params: {
    userId: string;
    documentId: string;
  }): Promise<void> {
    const { userId, documentId } = params;
    const docSnap = await this.db.collection("documents").doc(documentId).get();
    const document = docSnap.data() as { userId?: string } | undefined;

    if (!docSnap.exists || !document?.userId || document.userId !== userId) {
      throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
    }
  }

  private toChatHistoryMessage(message: ChatMessageRecord): ChatHistoryMessage {
    return {
      role: message.role,
      content: message.content,
      sources: message.sources ?? [],
      timestamp:
        this.toIsoString(message.timestamp) ?? new Date().toISOString(),
    };
  }

  private toIsoString(timestamp?: unknown): string | null {
    if (typeof timestamp === "string") {
      return timestamp;
    }

    if (
      timestamp &&
      typeof (timestamp as { toDate?: unknown }).toDate === "function"
    ) {
      return (timestamp as { toDate: () => Date }).toDate().toISOString();
    }

    return null;
  }

  private toMillis(timestamp?: unknown): number {
    if (
      timestamp &&
      typeof (timestamp as { toMillis?: unknown }).toMillis === "function"
    ) {
      return (timestamp as { toMillis: () => number }).toMillis();
    }

    if (typeof timestamp === "string") {
      const parsed = Date.parse(timestamp);
      return Number.isNaN(parsed) ? 0 : parsed;
    }

    return 0;
  }

  private chunkMessages(
    messages: ChatMessageRecord[],
    size: number,
  ): ChatMessageRecord[][] {
    const pages: ChatMessageRecord[][] = [];
    for (let i = 0; i < messages.length; i += size) {
      pages.push(messages.slice(i, i + size));
    }
    return pages;
  }
}
