/**
 * RagQueryService Unit Tests
 * Story 5.4: RAG query service logic
 */

import { describe, it, expect, beforeEach, jest } from "@jest/globals";
import type { Firestore } from "firebase-admin/firestore";
import type { HumanMessage, SystemMessage } from "@langchain/core/messages";
import { RagQueryService } from "../../../src/services/rag-query.service";

jest.mock("../../../src/utils/logger", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

describe("RagQueryService", () => {
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
  type PineconeQuery = (params: {
    vector: number[];
    topK: number;
    includeMetadata: boolean;
    filter?: Record<string, unknown>;
  }) => Promise<PineconeQueryResponse>;

  const embedQuery = jest.fn() as jest.MockedFunction<EmbedQuery>;
  const invoke = jest.fn() as jest.MockedFunction<Invoke>;
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

    const service = new RagQueryService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke },
    });

    const response = await service.queryDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "Test",
    });

    expect(response.answer).toBe(
      "I don't have information about that in your document.",
    );
    expect(response.sources).toEqual([]);
    expect(response.confidence).toBe(0);
    expect(invoke).not.toHaveBeenCalled();
  });

  it("should fetch chunks and map sources", async () => {
    pineconeQuery.mockResolvedValue({
      matches: [
        {
          score: 0.9,
          metadata: { chunkIndex: 1, pageNumber: 2, textPreview: "Preview" },
        },
      ],
    });

    const service = new RagQueryService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke },
    });

    const response = await service.queryDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "Test",
    });

    expect(chunksCollection.doc).toHaveBeenCalledWith("1");
    expect(response.sources).toEqual([{ pageNumber: 2, snippet: "Preview" }]);
    expect(response.answer).toBe("Answer");
    // Confidence is now scaled: (0.9 - 0.7) / (1 - 0.7) * 0.9 + 0.1 = 0.7
    expect(response.confidence).toBeCloseTo(0.7, 1);
  });

  it("should query pinecone with user and document filter", async () => {
    pineconeQuery.mockResolvedValue({
      matches: [
        {
          score: 0.95,
          metadata: { chunkIndex: 0, pageNumber: 1, textPreview: "Preview" },
        },
      ],
    });

    const service = new RagQueryService({
      db,
      pineconeIndex,
      embeddingModel: { embedQuery },
      llm: { invoke },
    });

    await service.queryDocument({
      userId: "user-1",
      documentId: "doc-1",
      question: "Test",
    });

    expect(pineconeIndex.namespace).toHaveBeenCalledWith("user-1");
    expect(pineconeQuery).toHaveBeenCalledWith({
      vector: [0.1, 0.2],
      topK: 3,
      includeMetadata: true,
      filter: {
        userId: { $eq: "user-1" },
        documentId: { $eq: "doc-1" },
      },
    });
  });
});
