import { GoogleGenerativeAIEmbeddings } from "@langchain/google-genai";
import { TaskType } from "@google/generative-ai";
import { getIndex } from "../config/pinecone";
import { env } from "../config/env";
import { retryWithBackoff } from "../utils/async";
import { logger } from "../config/logger";
import { AppError } from "../errors/app-error";

// Interfaces for input/output
import { ChunkWithMetadata } from "../types/document.types";

export class EmbeddingService {
  private embeddingsModel: GoogleGenerativeAIEmbeddings;
  private readonly BATCH_SIZE = 10;
  private readonly EMBEDDING_DIMENSION = 768; // Gemini embedding-001 dimension

  constructor() {
    this.embeddingsModel = new GoogleGenerativeAIEmbeddings({
      apiKey: env.GEMINI_API_KEY,
      modelName: "embedding-001",
      taskType: TaskType.RETRIEVAL_DOCUMENT,
    });
  }

  /**

* Generates an embedding vector for a single string of text.
* Retries on transient API failures.
*/
  async generateEmbedding(text: string): Promise<number[]> {
    try {
      return await retryWithBackoff(async () => {
        return await this.embeddingsModel.embedQuery(text);
      });
    } catch (error) {
      logger.error("Failed to generate embedding", error);
      throw new AppError(502, "Failed to generate embedding from AI provider");
    }
  }

  /**

* Generates embeddings for a batch of text chunks.
* Handles rate limiting by processing in small batches.
*/
  async generateBatchEmbeddings(
    chunks: ChunkWithMetadata[]
  ): Promise<number[][]> {
    const texts = chunks.map((chunk) => chunk.text);
    const allEmbeddings: number[][] = [];

    // Process in batches to avoid rate limits
    for (let i = 0; i < texts.length; i += this.BATCH_SIZE) {
      const batchTexts = texts.slice(i, i + this.BATCH_SIZE);

      try {
        const batchEmbeddings = await retryWithBackoff(async () => {
          return await this.embeddingsModel.embedDocuments(batchTexts);
        });

        // Validate dimensions
        batchEmbeddings.forEach((emb) => {
          if (emb.length !== this.EMBEDDING_DIMENSION) {
            logger.warn(
              `Unexpected embedding dimension: ${emb.length}, expected ${this.EMBEDDING_DIMENSION}`
            );
          }
        });

        allEmbeddings.push(...batchEmbeddings);
      } catch (error) {
        logger.error(
          `Failed to generate embeddings for batch starting at index ${i}`,
          error
        );
        throw new AppError(502, "Failed to generate batch embeddings");
      }
    }

    return allEmbeddings;
  }

  /**

* Stores embeddings and their metadata in Pinecone.
* Uses a user-specific namespace for data isolation.
*/
  async storeEmbeddings(
    documentId: string,
    userId: string,
    chunks: ChunkWithMetadata[],
    embeddings: number[][]
  ): Promise<void> {
    if (chunks.length !== embeddings.length) {
      throw new AppError(500, "Mismatch between chunks and embeddings count");
    }

    const index = getIndex();
    const namespace = `user_${userId}`;

    // Prepare Pinecone vectors
    const vectors = chunks.map((chunk, i) => ({
      id: `${documentId}_chunk_${chunk.metadata.chunkIndex}`,
      values: embeddings[i],
      metadata: {
        documentId,
        documentName: chunk.metadata.documentName ?? "",
        pageNumber: chunk.metadata.pageNumber,
        chunkIndex: chunk.metadata.chunkIndex,
        text: chunk.text, // Store text for retrieval
        userId,
      },
    }));

    // Upsert to Pinecone in batches (Pinecone has a limit on request size, usually 2MB or 100-500 vectors)
    const PINECONE_BATCH_SIZE = 50;

    for (let i = 0; i < vectors.length; i += PINECONE_BATCH_SIZE) {
      const batchVectors = vectors.slice(i, i + PINECONE_BATCH_SIZE);

      try {
        await retryWithBackoff(async () => {
          await index.namespace(namespace).upsert(batchVectors);
        });
      } catch (error) {
        logger.error(
          `Failed to store embeddings in Pinecone for doc ${documentId}`,
          error
        );
        throw new AppError(502, "Failed to store vector embeddings");
      }
    }

    logger.info(
      `Stored ${vectors.length} vectors for document ${documentId} in namespace ${namespace}`
    );
  }
}

// Export singleton instance
export const embeddingService = new EmbeddingService();
