/**
 * Vector Service
 * Handles Pinecone vector storage for document embeddings
 * Story 3.7: Implement Vector Storage in Pinecone
 */

import { index } from "../config";
import {
  ProcessingError,
  RateLimitError,
  ValidationError,
} from "../types/api.types";
import type { EmbeddingResult } from "../types/embedding.types";
import type {
  VectorMetadata,
  VectorStorageRequest,
} from "../types/vector.types";
import { logger } from "../utils/logger";

export interface UpsertDocumentEmbeddingsParams {
  userId: string;
  documentId: string;
  embeddings: EmbeddingResult[];
}

interface PineconeIndex {
  upsert: (params: {
    vectors: VectorStorageRequest[];
    namespace?: string;
  }) => Promise<unknown>;
}

export class VectorService {
  private readonly embeddingDimensions = 768;
  private readonly maxBatchSize = 100;
  private readonly maxRetries = 3;
  private readonly baseBackoffMs = 500;

  constructor(
    private readonly pineconeIndex: PineconeIndex | undefined = index,
  ) {}

  /**
   * Upsert document embeddings into Pinecone
   */
  async upsertDocumentEmbeddings(
    params: UpsertDocumentEmbeddingsParams,
  ): Promise<{ vectorCount: number }> {
    const { userId, documentId, embeddings } = params;

    if (!userId || !documentId) {
      throw new ValidationError("Missing userId or documentId", {
        userId,
        documentId,
      });
    }

    if (!embeddings || embeddings.length === 0) {
      throw new ValidationError("No embeddings provided for upsert", {
        documentId,
      });
    }

    if (!this.pineconeIndex) {
      throw new ProcessingError("Pinecone index is not configured", {
        documentId,
      });
    }

    const vectors = this.mapToVectors(userId, documentId, embeddings);
    const batches = this.chunkIntoBatches(vectors, this.maxBatchSize);

    for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      const batch = batches[batchIndex];
      await this.upsertBatchWithRetry({
        userId,
        documentId,
        batch,
        batchIndex,
      });
    }

    return { vectorCount: vectors.length };
  }

  private mapToVectors(
    userId: string,
    documentId: string,
    embeddings: EmbeddingResult[],
  ): VectorStorageRequest[] {
    const chunkIndices = new Set<number>();

    return embeddings.map((embedding) => {
      const { chunkIndex, pageNumber, textPreview } = embedding.metadata;

      if (!Number.isInteger(chunkIndex) || chunkIndex < 0) {
        throw new ValidationError("Invalid chunkIndex in embedding metadata", {
          documentId,
          chunkIndex,
        });
      }

      if (chunkIndices.has(chunkIndex)) {
        throw new ValidationError("Duplicate chunkIndex detected", {
          documentId,
          chunkIndex,
        });
      }

      chunkIndices.add(chunkIndex);

      if (embedding.vector.length !== this.embeddingDimensions) {
        throw new ValidationError("Embedding dimension mismatch", {
          documentId,
          chunkIndex,
          expected: this.embeddingDimensions,
          received: embedding.vector.length,
        });
      }

      const metadata: VectorMetadata = {
        userId,
        documentId,
        pageNumber,
        chunkIndex,
        textPreview,
      };

      return {
        id: `${documentId}_${chunkIndex}`,
        values: embedding.vector,
        metadata,
      };
    });
  }

  private async upsertBatchWithRetry(params: {
    userId: string;
    documentId: string;
    batch: VectorStorageRequest[];
    batchIndex: number;
  }): Promise<void> {
    const { userId, documentId, batch, batchIndex } = params;
    let lastError: unknown;

    for (let attempt = 1; attempt <= this.maxRetries; attempt++) {
      try {
        await this.pineconeIndex?.upsert({
          vectors: batch,
          namespace: userId,
        });

        logger.info("Pinecone upsert batch completed", {
          userId,
          documentId,
          batchIndex,
          batchSize: batch.length,
          attempt,
        });

        return;
      } catch (error) {
        lastError = error;

        if (this.isRateLimitError(error) && attempt < this.maxRetries) {
          const delayMs = this.calculateBackoff(attempt);
          logger.warn("Pinecone rate limit hit, retrying batch", {
            userId,
            documentId,
            batchIndex,
            batchSize: batch.length,
            attempt,
            delayMs,
            error: error instanceof Error ? error.message : String(error),
          });
          await this.delay(delayMs);
          continue;
        }

        if (this.isRateLimitError(error)) {
          throw new RateLimitError("Pinecone rate limit exceeded", {
            documentId,
            batchIndex,
            attempts: attempt,
          });
        }

        throw new ProcessingError("Pinecone upsert failed", {
          documentId,
          batchIndex,
          attempts: attempt,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    throw new ProcessingError("Pinecone upsert failed", {
      documentId,
      batchIndex,
      attempts: this.maxRetries,
      error: lastError instanceof Error ? lastError.message : String(lastError),
    });
  }

  private chunkIntoBatches<T>(items: T[], size: number): T[][] {
    const batches: T[][] = [];
    for (let i = 0; i < items.length; i += size) {
      batches.push(items.slice(i, i + size));
    }
    return batches;
  }

  private calculateBackoff(attempt: number): number {
    const jitter = Math.floor(Math.random() * 200);
    return this.baseBackoffMs * Math.pow(2, attempt - 1) + jitter;
  }

  private async delay(ms: number): Promise<void> {
    await new Promise((resolve) => setTimeout(resolve, ms));
  }

  private isRateLimitError(error: unknown): boolean {
    if (!error) return false;
    if (typeof error === "object") {
      const status = (error as { status?: number; statusCode?: number }).status;
      const statusCode = (error as { statusCode?: number }).statusCode;
      if (status === 429 || statusCode === 429) {
        return true;
      }
    }
    const message =
      error instanceof Error ? error.message.toLowerCase() : String(error);
    return message.includes("rate limit") || message.includes("429");
  }
}
