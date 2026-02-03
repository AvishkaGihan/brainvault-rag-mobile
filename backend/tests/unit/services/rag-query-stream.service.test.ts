/**
 * RagQueryStreamService Unit Tests
 * Story 5.7: Hallucination prevention
 */

import { describe, it, expect, beforeEach, jest } from "@jest/globals";
import type { Firestore } from "firebase-admin/firestore";
import type { HumanMessage, SystemMessage } from "@langchain/core/messages";
import {
  NO_CONTEXT_ANSWER,
  OUT_OF_SCOPE_ANSWER,
} from "../../../src/constants/rag-fallbacks";
import { RagQueryStreamService } from "../../../src/services/rag-query-stream.service";

jest.mock("../../../src/utils/logger", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

describe("RagQueryStreamService", () => {
  type PineconeQueryResponse = {
    matches?: Array<{
      score?: number;
      metadata?: {
        chunkIndex?: number;
        pageNumber?: number;
        textPreview?: string;
      };
    }>;
  };

  type EmbedQuery = (text: string) => Promise<number[]>;
  type Invoke = (
    messages: Array<SystemMessage | HumanMessage>,
  ) => Promise<{ content: unknown }>;
  type Stream = (
    messages: Array<SystemMessage | HumanMessage>,
  ) =>
    | AsyncIterable<{ content: unknown }>
    | Promise<AsyncIterable<{ content: unknown }>>;
  type PineconeQuery = (params: {
    vector: number[];
    topK: number;
    includeMetadata: boolean;
    filter?: Record<string, unknown>;
  }) => Promise<PineconeQueryResponse>;

  const embedQuery = jest.fn() as jest.MockedFunction<EmbedQuery>;
  const invoke = jest.fn() as jest.MockedFunction<Invoke>;
  const stream = jest.fn() as jest.MockedFunction<Stream>;
  const pineconeQuery = jest.fn() as jest.MockedFunction<PineconeQuery>;
  const pineconeNamespace = { query: pineconeQuery };
  const pineconeIndex = {
    namespace: jest.fn((_: string) => pineconeNamespace),
  };

  type ChunkGet = () => Promise<{
    exists: boolean;
    data: () =>
      | {
          text?: string;
          pageNumber?: number;
          textPreview?: string;
        }
      | undefined;
  }>;

  const chunkGet = jest.fn() as jest.MockedFunction<ChunkGet>;
  const chunkDoc = { get: chunkGet };
  const chunksCollection = {
    doc: jest.fn(() => chunkDoc),
  };
  type DocGet = () => Promise<{
    exists: boolean;
    data: () => { userId?: string; status?: string; title?: string };
  }>;

  const docGet = jest.fn() as jest.MockedFunction<DocGet>;
  const documentRef = {
    get: docGet,
    collection: jest.fn(() => chunksCollection),
  };
  const collection = {
    doc: jest.fn(() => documentRef),
  };
  const db = {
    collection: jest.fn(() => collection),
  } as unknown as Firestore;

  beforeEach(() => {
    jest.clearAllMocks();
    embedQuery.mockResolvedValue([0.1, 0.2]);
    invoke.mockResolvedValue({ content: "Answer" });
    docGet.mockResolvedValue({
      exists: true,
      data: () => ({ userId: "user-1", status: "ready", title: "Doc" }),
    });
    chunkGet.mockResolvedValue({
      exists: true,
      data: () => ({
        text: "Chunk text",
        pageNumber: 2,
        textPreview: "Preview",
      }),
    });
  });

  it("should return fallback when scores below threshold", async () => {
    pineconeQuery.mockResolvedValue({
      matches: [{ score: 0.6, metadata: { chunkIndex: 0, pageNumber: 1 } }],
    });

    const service = new RagQueryStreamService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke, stream },
    });

    const response = await service.streamDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "Test",
    });

    expect(response.stream).toBeNull();
    expect(response.done.answer).toBe(NO_CONTEXT_ANSWER);
    expect(response.done.sources).toEqual([]);
    expect(response.done.confidence).toBe(0);
    expect(invoke).not.toHaveBeenCalled();
    expect(stream).not.toHaveBeenCalled();
  });

  it("should override sources and confidence when streaming returns no-context", async () => {
    pineconeQuery.mockResolvedValue({
      matches: [
        {
          score: 0.95,
          metadata: { chunkIndex: 0, pageNumber: 1, textPreview: "Preview" },
        },
      ],
    });

    stream.mockImplementation(async function* () {
      yield { content: NO_CONTEXT_ANSWER };
    });

    const service = new RagQueryStreamService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke, stream },
    });

    const response = await service.streamDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "Test",
    });

    if (!response.stream) {
      throw new Error("Expected stream to be defined");
    }

    for await (const _ of response.stream) {
      // consume
    }

    expect(response.done.answer).toBe(NO_CONTEXT_ANSWER);
    expect(response.done.sources).toEqual([]);
    expect(response.done.confidence).toBe(0);
  });

  it("should return out-of-scope response without invoking LLM", async () => {
    const service = new RagQueryStreamService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke, stream },
    });

    const response = await service.streamDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "What's the weather today?",
    });

    expect(response.stream).toBeNull();
    expect(response.done.answer).toBe(OUT_OF_SCOPE_ANSWER);
    expect(response.done.sources).toEqual([]);
    expect(response.done.confidence).toBe(0);
    expect(embedQuery).not.toHaveBeenCalled();
    expect(pineconeQuery).not.toHaveBeenCalled();
    expect(invoke).not.toHaveBeenCalled();
    expect(stream).not.toHaveBeenCalled();
  });

  it("should NOT reject legitimate document questions with temporal keywords", async () => {
    const testQuestions = [
      "When was this document last updated?",
      "What time periods are covered in this?",
      "Can you find the date mentioned near the appendix?",
      "What information is current as of today in this document?",
    ];

    for (const question of testQuestions) {
      jest.clearAllMocks();
      pineconeQuery.mockResolvedValue({
        matches: [
          {
            score: 0.9,
            metadata: { chunkIndex: 0, pageNumber: 1, textPreview: "Preview" },
          },
        ],
      });
      stream.mockImplementation(async function* () {
        yield { content: "Answer" };
      });

      const service = new RagQueryStreamService({
        db,
        pineconeIndex,
        embeddingModel: { embedQuery },
        llm: { invoke, stream },
      });

      const response = await service.streamDocument({
        userId: "user-1",
        documentId: "doc-1",
        question,
      });

      // Should have called embedding and pinecone, not rejected as out-of-scope
      expect(embedQuery).toHaveBeenCalled();
      expect(pineconeQuery).toHaveBeenCalled();
      // Consume the stream to finalize the answer
      if (response.stream) {
        for await (const _ of response.stream) {
          // consume
        }
      }
      expect(response.done.answer).not.toBe(OUT_OF_SCOPE_ANSWER);
    }
  });
});
