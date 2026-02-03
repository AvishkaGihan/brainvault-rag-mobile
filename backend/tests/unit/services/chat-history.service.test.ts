/**
 * ChatHistoryService Unit Tests
 * Story 5.8: Chat history persistence
 */

import { describe, it, expect, beforeEach, jest } from "@jest/globals";
import { Timestamp, type Firestore } from "firebase-admin/firestore";
import { ChatHistoryService } from "../../../src/services/chat-history.service";
import type { ChatMessageRecord } from "../../../src/types/chat.types";

jest.mock("../../../src/utils/logger", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

describe("ChatHistoryService", () => {
  const userId = "user-1";
  const documentId = "doc-1";
  const chatId = "active";

  const createTimestamp = (date: Date): Timestamp => Timestamp.fromDate(date);

  let db: Firestore;
  let chatData: { messages: ChatMessageRecord[] } | null;
  let chatExists: boolean;
  let historyDocs: Array<{ id: string; data: any }>;

  beforeEach(() => {
    chatData = null;
    chatExists = false;
    historyDocs = [];

    const historyCollection = {
      doc: jest.fn(() => {
        const id = `history-${historyDocs.length + 1}`;
        return {
          id,
          set: jest.fn(async (data: any) => {
            historyDocs.push({ id, data });
          }),
        };
      }),
      orderBy: jest.fn(() => historyCollection),
      where: jest.fn(() => historyCollection),
      limit: jest.fn(() => historyCollection),
      get: jest.fn(async () => ({
        docs: historyDocs.map((doc) => ({
          id: doc.id,
          data: () => doc.data,
        })),
      })),
    };

    const chatRef = {
      get: jest.fn(async () => ({
        exists: chatExists,
        data: () => chatData ?? undefined,
      })),
      set: jest.fn(async (data: any) => {
        chatExists = true;
        chatData = { messages: data.messages ?? [] };
      }),
      update: jest.fn(async (data: any) => {
        chatExists = true;
        const existing = chatData ?? { messages: [] };
        chatData = {
          ...existing,
          ...data,
          messages: data.messages ?? existing.messages,
        };
      }),
      collection: jest.fn((name: string) => {
        if (name === "history") {
          return historyCollection;
        }
        throw new Error(`Unexpected subcollection: ${name}`);
      }),
    };

    const chatsCollection = {
      doc: jest.fn(() => chatRef),
    };

    const docRef = {
      get: jest.fn(async () => ({
        exists: true,
        data: () => ({ userId }),
      })),
      collection: jest.fn((name: string) => {
        if (name === "chats") {
          return chatsCollection;
        }
        throw new Error(`Unexpected subcollection: ${name}`);
      }),
    };

    const collection = {
      doc: jest.fn(() => docRef),
    };

    db = {
      collection: jest.fn(() => collection),
      runTransaction: jest.fn(async (fn: (tx: any) => Promise<any>) => {
        const tx = {
          get: jest.fn((ref: any) => ref.get()),
          set: jest.fn((ref: any, data: any) => ref.set(data)),
          update: jest.fn((ref: any, data: any) => ref.update(data)),
        };
        return fn(tx);
      }),
    } as unknown as Firestore;
  });

  it("should append messages in order", async () => {
    chatExists = true;
    chatData = {
      messages: [
        {
          role: "user",
          content: "Hello",
          sources: [],
          timestamp: createTimestamp(new Date("2026-01-01T00:00:00Z")),
        },
      ],
    };

    const service = new ChatHistoryService({ db });

    await service.appendMessages({
      userId,
      documentId,
      chatId,
      messages: [
        { role: "assistant", content: "Hi", sources: [] },
        { role: "user", content: "Question", sources: [] },
      ],
    });

    expect(chatData?.messages.map((msg) => msg.content)).toEqual([
      "Hello",
      "Hi",
      "Question",
    ]);
  });

  it("should retain last 100 messages on primary chat doc", async () => {
    chatExists = true;
    chatData = {
      messages: Array.from({ length: 100 }, (_, index) => ({
        role: "user",
        content: `m${index + 1}`,
        sources: [],
        timestamp: createTimestamp(new Date(Date.UTC(2026, 0, 1, 0, index, 0))),
      })),
    };

    const service = new ChatHistoryService({ db });

    await service.appendMessages({
      userId,
      documentId,
      chatId,
      messages: [
        { role: "assistant", content: "new-1", sources: [] },
        { role: "assistant", content: "new-2", sources: [] },
      ],
    });

    expect(chatData?.messages).toHaveLength(100);
    expect(chatData?.messages[0]?.content).toBe("m3");
    const lastMessage = chatData?.messages[chatData.messages.length - 1];
    expect(lastMessage?.content).toBe("new-2");
    expect(historyDocs).toHaveLength(1);
    expect(historyDocs[0]?.data?.messages).toHaveLength(2);
  });

  it("should return archived messages in chronological order", async () => {
    historyDocs.push({
      id: "history-1",
      data: {
        createdAt: createTimestamp(new Date("2026-01-01T01:00:00Z")),
        messages: [
          {
            role: "user",
            content: "old-1",
            sources: [],
            timestamp: createTimestamp(new Date("2026-01-01T00:10:00Z")),
          },
          {
            role: "assistant",
            content: "old-2",
            sources: [],
            timestamp: createTimestamp(new Date("2026-01-01T00:11:00Z")),
          },
        ],
      },
    });
    historyDocs.push({
      id: "history-2",
      data: {
        createdAt: createTimestamp(new Date("2026-01-01T02:00:00Z")),
        messages: [
          {
            role: "user",
            content: "old-3",
            sources: [],
            timestamp: createTimestamp(new Date("2026-01-01T00:12:00Z")),
          },
        ],
      },
    });

    const service = new ChatHistoryService({ db });

    const response = await service.getOlderMessages({
      userId,
      documentId,
      chatId,
      limit: 10,
    });

    expect(
      response.messages.map((msg: { content: string }) => msg.content),
    ).toEqual(["old-1", "old-2", "old-3"]);
  });
});
