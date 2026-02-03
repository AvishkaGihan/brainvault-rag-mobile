/**
 * RAG Query Service
 * Story 5.4: Implement RAG query pipeline
 */

import { HumanMessage, SystemMessage } from "@langchain/core/messages";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { createEmbeddingModel, createLLM } from "../config/llm";
import { index } from "../config/pinecone";
import { ragSystemPrompt } from "../prompts/rag_system_prompt";
import { AppError, ProcessingError, ValidationError } from "../types/api.types";
import type { ChatQueryResponseData, ChatSource } from "../types/chat.types";
import { logger } from "../utils/logger";

const NO_CONTEXT_ANSWER =
  "I don't have information about that in your document.";

interface PineconeQueryRequest {
  vector: number[];
  topK: number;
  includeMetadata: boolean;
  filter?: Record<string, unknown>;
}

interface PineconeMatch {
  score?: number;
  metadata?: {
    chunkIndex?: number;
    pageNumber?: number;
    textPreview?: string;
  };
}

interface PineconeQueryResponse {
  matches?: PineconeMatch[];
}

interface PineconeNamespace {
  query: (params: PineconeQueryRequest) => Promise<PineconeQueryResponse>;
}

interface PineconeIndex {
  namespace: (ns: string) => PineconeNamespace;
}

interface EmbeddingModel {
  embedQuery: (text: string) => Promise<number[]>;
}

interface LlmModel {
  invoke: (messages: Array<SystemMessage | HumanMessage>) => Promise<{
    content: unknown;
  }>;
}

interface RagQueryDependencies {
  db?: Firestore;
  pineconeIndex?: PineconeIndex;
  embeddingModel?: EmbeddingModel;
  llm?: LlmModel;
}

export class RagQueryService {
  private readonly db: Firestore;
  private readonly pineconeIndex: PineconeIndex | undefined;
  private readonly embeddingModel: EmbeddingModel;
  private readonly llm: LlmModel;
  private readonly topK = 3;
  private readonly similarityThreshold = 0.7;

  constructor(deps: RagQueryDependencies = {}) {
    this.db = deps.db ?? getFirestore();
    this.pineconeIndex = deps.pineconeIndex ?? (index as PineconeIndex);
    this.embeddingModel = deps.embeddingModel ?? createEmbeddingModel();
    this.llm = deps.llm ?? createLLM();
  }

  /**
   * Query a document with RAG pipeline
   */
  async queryDocument(params: {
    userId: string;
    documentId: string;
    question: string;
  }): Promise<ChatQueryResponseData> {
    const { userId, documentId, question } = params;
    const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    if (!userId || !documentId) {
      throw new ValidationError("Missing userId or documentId", {
        userId,
        documentId,
      });
    }

    if (!question || question.trim().length === 0) {
      throw new ValidationError("Question must not be empty", {
        questionLength: question?.length ?? 0,
      });
    }

    if (!this.pineconeIndex) {
      throw new AppError(
        "CONFIGURATION_ERROR",
        "Vector index is not configured",
        500,
      );
    }

    const startTime = Date.now();

    try {
      const documentSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!documentSnapshot.exists) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      const document = documentSnapshot.data() as
        | { userId?: string; status?: string; title?: string }
        | undefined;

      if (!document || document.userId !== userId) {
        throw new AppError(
          "UNAUTHORIZED",
          "You do not have permission to access this document",
          403,
        );
      }

      if (document.status !== "ready") {
        throw new AppError(
          "INVALID_DOCUMENT",
          "Document is not ready for chat",
          409,
        );
      }

      const embeddingStart = Date.now();
      const queryEmbedding = await this.embeddingModel.embedQuery(
        question.trim(),
      );
      const embeddingMs = Date.now() - embeddingStart;

      const pineconeStart = Date.now();
      const pineconeResponse = await this.pineconeIndex
        .namespace(userId)
        .query({
          vector: queryEmbedding,
          topK: this.topK,
          includeMetadata: true,
          filter: {
            userId: { $eq: userId },
            documentId: { $eq: documentId },
          },
        });
      const pineconeMs = Date.now() - pineconeStart;

      const matches = pineconeResponse.matches ?? [];
      const relevantMatches = matches.filter(
        (match) =>
          typeof match.score === "number" &&
          match.score >= this.similarityThreshold,
      );

      if (relevantMatches.length === 0) {
        logger.info("No relevant context found for chat query", {
          requestId,
          userId,
          documentId,
          matchCount: matches.length,
          questionLength: question.length,
          embeddingMs,
          pineconeMs,
        });

        return {
          answer: NO_CONTEXT_ANSWER,
          sources: [],
          confidence: 0,
        };
      }

      const chunkFetchStart = Date.now();
      const chunks = await Promise.all(
        relevantMatches.map(async (match) =>
          this.fetchChunk({
            documentId,
            match,
          }),
        ),
      );
      const chunkFetchMs = Date.now() - chunkFetchStart;

      const resolvedChunks = chunks.filter(
        (chunk): chunk is NonNullable<typeof chunk> => Boolean(chunk),
      );

      if (resolvedChunks.length === 0) {
        logger.warn("No valid chunks found after query", {
          requestId,
          userId,
          documentId,
          matchCount: relevantMatches.length,
        });

        return {
          answer: NO_CONTEXT_ANSWER,
          sources: [],
          confidence: 0,
        };
      }

      const documentTitle = document.title || "Document";
      const context = resolvedChunks
        .map(
          (chunk) =>
            `[Source: ${documentTitle}, Page ${chunk.pageNumber}]\n${chunk.text}`,
        )
        .join("\n\n");

      const llmStart = Date.now();
      const llmResponse = await this.llm.invoke([
        new SystemMessage(ragSystemPrompt),
        new HumanMessage(`Context:\n${context}\n\nQuestion: ${question}`),
      ]);
      const llmMs = Date.now() - llmStart;

      const answer =
        typeof llmResponse.content === "string"
          ? llmResponse.content.trim()
          : String(llmResponse.content ?? "").trim();

      const confidence = this.calculateConfidence(relevantMatches);
      const sources: ChatSource[] = resolvedChunks.map((chunk) => ({
        pageNumber: chunk.pageNumber,
        snippet: chunk.snippet,
      }));

      logger.info("RAG query completed", {
        requestId,
        userId,
        documentId,
        matchCount: matches.length,
        relevantCount: relevantMatches.length,
        embeddingMs,
        pineconeMs,
        chunkFetchMs,
        llmMs,
        totalMs: Date.now() - startTime,
        questionLength: question.length,
      });

      return {
        answer,
        sources,
        confidence,
      };
    } catch (error) {
      logger.error("RAG query failed", {
        requestId,
        userId,
        documentId,
        error: error instanceof Error ? error.message : String(error),
      });

      if (error instanceof AppError) {
        throw error;
      }

      throw new ProcessingError("Chat query failed", {
        userId,
        documentId,
      });
    }
  }

  private async fetchChunk(params: {
    documentId: string;
    match: PineconeMatch;
  }): Promise<
    | {
        pageNumber: number;
        text: string;
        snippet: string;
      }
    | undefined
  > {
    const { documentId, match } = params;
    const chunkIndex = this.parseChunkIndex(match);
    if (chunkIndex === null) {
      return undefined;
    }

    const chunkSnapshot = await this.db
      .collection("documents")
      .doc(documentId)
      .collection("chunks")
      .doc(String(chunkIndex))
      .get();

    if (!chunkSnapshot.exists) {
      return undefined;
    }

    const chunkData = chunkSnapshot.data() as
      | { text?: string; pageNumber?: number; textPreview?: string }
      | undefined;

    if (!chunkData?.text) {
      return undefined;
    }

    const pageNumber = this.resolvePageNumber(match, chunkData);
    const snippet =
      chunkData.textPreview?.toString() ?? chunkData.text.substring(0, 200);

    return {
      pageNumber,
      text: chunkData.text,
      snippet,
    };
  }

  private parseChunkIndex(match: PineconeMatch): number | null {
    const chunkIndex = match.metadata?.chunkIndex;
    if (typeof chunkIndex === "number" && Number.isFinite(chunkIndex)) {
      return chunkIndex;
    }
    return null;
  }

  private resolvePageNumber(
    match: PineconeMatch,
    chunkData: { pageNumber?: number },
  ): number {
    if (typeof chunkData.pageNumber === "number") {
      return chunkData.pageNumber;
    }
    const metaPageNumber = match.metadata?.pageNumber;
    if (typeof metaPageNumber === "number") {
      return metaPageNumber;
    }
    return 0;
  }

  private calculateConfidence(matches: PineconeMatch[]): number {
    const scores = matches
      .map((match) => match.score)
      .filter((score): score is number => typeof score === "number");

    if (scores.length === 0) {
      return 0;
    }

    const maxScore = scores.reduce((max, current) =>
      current > max ? current : max,
    );

    // Scale confidence: threshold (0.7) -> 0.1, perfect (1.0) -> 1.0
    // This prevents marginal matches from appearing overly confident
    const threshold = this.similarityThreshold;
    if (maxScore < threshold) {
      return 0;
    }
    const scaled = (maxScore - threshold) / (1 - threshold);
    return Math.max(0, Math.min(1, scaled * 0.9 + 0.1));
  }
}
