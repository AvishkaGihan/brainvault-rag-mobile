import { describe, it, expect, beforeEach, jest } from "@jest/globals";
import { VectorService } from "../../../src/services/vector.service";
import { RateLimitError } from "../../../src/types/api.types";
import type { EmbeddingResult } from "../../../src/types/embedding.types";

jest.mock("../../../src/utils/logger", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

const createEmbedding = (chunkIndex: number): EmbeddingResult => ({
  vector: Array.from({ length: 768 }, () => 0.1),
  metadata: {
    pageNumber: 1,
    chunkIndex,
    textPreview: "preview text",
  },
});

describe("VectorService", () => {
  type UpsertParams = {
    vectors: Array<{
      id: string;
      values: number[];
      metadata: Record<string, unknown>;
    }>;
    namespace?: string;
  };
  let mockIndex: {
    upsert: jest.MockedFunction<(params: UpsertParams) => Promise<unknown>>;
  };

  beforeEach(() => {
    jest.clearAllMocks();
    const upsert = jest
      .fn(async (_params: UpsertParams) => ({}))
      .mockResolvedValue({}) as jest.MockedFunction<
      (params: UpsertParams) => Promise<unknown>
    >;

    mockIndex = {
      upsert,
    };
  });

  it("should map embeddings to Pinecone vectors with correct metadata", async () => {
    const service = new VectorService(mockIndex);

    await service.upsertDocumentEmbeddings({
      userId: "user-1",
      documentId: "doc-1",
      embeddings: [createEmbedding(0), createEmbedding(1)],
    });

    expect(mockIndex.upsert).toHaveBeenCalledTimes(1);
    const call = mockIndex.upsert.mock.calls[0][0];
    expect(call.namespace).toBe("user-1");
    expect(call.vectors).toHaveLength(2);
    expect(call.vectors[0].id).toBe("doc-1_0");
    expect(call.vectors[0].metadata).toEqual({
      userId: "user-1",
      documentId: "doc-1",
      pageNumber: 1,
      chunkIndex: 0,
      textPreview: "preview text",
    });
    expect(call.vectors[0].values).toHaveLength(768);
  });

  it("should batch upserts into max 100 vectors", async () => {
    const service = new VectorService(mockIndex);
    const embeddings = Array.from({ length: 250 }, (_, index) =>
      createEmbedding(index),
    );

    await service.upsertDocumentEmbeddings({
      userId: "user-2",
      documentId: "doc-2",
      embeddings,
    });

    expect(mockIndex.upsert).toHaveBeenCalledTimes(3);
    expect(mockIndex.upsert.mock.calls[0][0].vectors).toHaveLength(100);
    expect(mockIndex.upsert.mock.calls[1][0].vectors).toHaveLength(100);
    expect(mockIndex.upsert.mock.calls[2][0].vectors).toHaveLength(50);
  });

  it("should retry on rate limit and eventually succeed", async () => {
    jest.useFakeTimers();
    const randomSpy = jest.spyOn(Math, "random").mockReturnValue(0);

    mockIndex.upsert
      .mockRejectedValueOnce({ status: 429 })
      .mockResolvedValueOnce({});

    const service = new VectorService(mockIndex);
    const promise = service.upsertDocumentEmbeddings({
      userId: "user-3",
      documentId: "doc-3",
      embeddings: [createEmbedding(0)],
    });

    await jest.advanceTimersByTimeAsync(500);
    await promise;

    expect(mockIndex.upsert).toHaveBeenCalledTimes(2);

    randomSpy.mockRestore();
    jest.useRealTimers();
  });

  it("should throw RateLimitError after retry exhaustion", async () => {
    jest.useFakeTimers();
    const randomSpy = jest.spyOn(Math, "random").mockReturnValue(0);

    mockIndex.upsert.mockRejectedValue({ status: 429 });

    const service = new VectorService(mockIndex);
    const promise = service.upsertDocumentEmbeddings({
      userId: "user-4",
      documentId: "doc-4",
      embeddings: [createEmbedding(0)],
    });

    const expectation = expect(promise).rejects.toBeInstanceOf(RateLimitError);

    await jest.advanceTimersByTimeAsync(500);
    await jest.advanceTimersByTimeAsync(1000);

    await expectation;

    randomSpy.mockRestore();
    jest.useRealTimers();
  });
});
