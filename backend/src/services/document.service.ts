import { getFirestore, FieldValue } from "firebase-admin/firestore";
import type { DocumentReference } from "firebase-admin/firestore";
import {
  generateStoragePath,
  uploadToStorage,
  deleteFromStorage,
} from "../config/storage";
import { validatePDFContent, validateTextDocument } from "../utils/validation";
import { AppError, ValidationError } from "../types/api.types";
import type {
  Document,
  CreateDocumentDTO,
  DocumentStatusResponse,
} from "../types/document.types";
import type { EmbeddingInputChunk } from "../types/embedding.types";
import { logger } from "../utils/logger";
import { EmbeddingService } from "./embedding.service";
import { VectorService } from "./vector.service";

/**
 * Document Service
 * Business logic for document upload and management
 * AC1, AC3, AC6, AC8: Document creation with validation and error recovery
 */
export class DocumentService {
  private db = getFirestore();
  private embeddingService = new EmbeddingService();
  private vectorService = new VectorService();

  /**
   * Upload PDF document to Storage and create Firestore record
   * AC1: PDF upload endpoint with validation
   * AC6: User isolation and data association
   * AC8: Error recovery and cleanup
   *
   * @param userId - User's Firebase UID from auth middleware
   * @param file - Multer file object with buffer
   * @returns Created document record
   */
  async uploadPDFDocument(
    userId: string,
    file: Express.Multer.File,
  ): Promise<Document> {
    // Validate PDF content (defense in depth)
    // AC2: Server-side validation - NEVER trust client
    validatePDFContent(file.buffer);

    // Generate unique document ID
    const docRef = this.db.collection("documents").doc();
    const documentId = docRef.id;

    // Generate storage path with user isolation
    const storagePath = generateStoragePath(userId, documentId);

    try {
      // Upload file to Firebase Storage
      await uploadToStorage(file.buffer, storagePath, file.mimetype);

      // Create Firestore document record
      const documentData: CreateDocumentDTO = {
        id: documentId,
        userId, // CRITICAL: User isolation
        title: file.originalname,
        fileName: file.originalname,
        fileSize: file.size,
        pageCount: 0, // Will be updated in Story 3.4 after PDF parsing
        status: "processing",
        storagePath,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };

      await docRef.set(documentData);

      // Return document with actual timestamp
      const created = await docRef.get();
      const document = created.data() as Document;

      // Trigger background processing pipeline (Story 3.6)
      this.triggerTextExtraction(documentId).catch((error) => {
        logger.error("Background processing failed for uploaded document", {
          documentId,
          userId,
          error: error instanceof Error ? error.message : String(error),
        });
      });

      return document;
    } catch (error) {
      // AC8: Cleanup on error - remove partial data
      await deleteFromStorage(storagePath);

      // Attempt to delete Firestore doc if created
      try {
        await docRef.delete();
      } catch (deleteError) {
        logger.error("Failed to cleanup Firestore document", {
          originalError:
            deleteError instanceof Error
              ? deleteError.message
              : String(deleteError),
        });
      }

      throw new AppError(
        "UPLOAD_FAILED",
        "Failed to upload document. Please try again.",
        500,
        { originalError: (error as Error).message },
      );
    }
  }

  /**
   * Create text-only document (no file upload)
   * AC3: Text document endpoint
   * AC4: Text content validation
   * AC6: User isolation
   *
   * @param userId - User's Firebase UID
   * @param title - Document title
   * @param content - Text content
   * @returns Created document record
   */
  async createTextDocument(
    userId: string,
    title: string,
    content: string,
  ): Promise<Document> {
    // AC4: Validate text document input
    validateTextDocument(title, content);

    // Generate unique document ID
    const docRef = this.db.collection("documents").doc();
    const documentId = docRef.id;

    const documentData: CreateDocumentDTO = {
      id: documentId,
      userId, // CRITICAL: User isolation
      title,
      fileName: `${title}.txt`,
      fileSize: content.length, // Character count
      pageCount: 1, // Text documents treated as single page
      status: "processing",
      content, // Store content directly in Firestore (text only)
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    await docRef.set(documentData);

    // Return document with actual timestamp
    const created = await docRef.get();
    const document = created.data() as Document;

    // Trigger background processing pipeline (Story 3.6)
    this.triggerTextExtraction(documentId).catch((error) => {
      logger.error("Background processing failed for text document", {
        documentId,
        userId,
        error: error instanceof Error ? error.message : String(error),
      });
    });

    return document;
  }

  /**
   * Get document processing status
   * AC2: Status endpoint with user isolation and non-leaking errors
   */
  async getDocumentStatus(
    userId: string,
    documentId: string,
  ): Promise<DocumentStatusResponse> {
    const docSnap = await this.db.collection("documents").doc(documentId).get();

    const document = docSnap.data() as Document | undefined;

    if (!document || document.userId !== userId) {
      throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
    }

    // Convert Firestore Timestamp to ISO string
    // Firestore Timestamp has toDate() method that returns Date object
    const timestampDate = (document.updatedAt || document.createdAt) as any;
    const updatedAt =
      timestampDate && typeof timestampDate.toDate === "function"
        ? timestampDate.toDate()
        : new Date();

    return {
      documentId,
      status: document.status,
      ...(document.errorMessage && { errorMessage: document.errorMessage }),
      updatedAt: updatedAt.toISOString(),
    };
  }

  /**
   * Cancel an in-flight document upload or processing
   * Story 3.9: Upload cancellation
   */
  async cancelDocument(
    userId: string,
    documentId: string,
  ): Promise<{ documentId: string; cancelled: true }> {
    const docRef = this.db.collection("documents").doc(documentId);

    const document = await this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      const data = snapshot.data() as Document | undefined;

      if (!data || data.userId !== userId) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      if (data.status === "ready") {
        throw new AppError(
          "CANCEL_NOT_ALLOWED",
          "Document is already processed",
          409,
        );
      }

      transaction.update(docRef, {
        cancelRequestedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      return data;
    });

    let chunkIds: string[] = [];

    try {
      chunkIds = await this.fetchChunkIds(docRef, documentId);
    } catch (error) {
      logger.warn("Failed to load document chunks for cancellation", {
        documentId,
        userId,
        error: error instanceof Error ? error.message : String(error),
      });
    }

    // Step 1: Delete vectors first (prevents orphaned vectors)
    if (chunkIds.length > 0) {
      const vectorIds = chunkIds.map((chunkId) => `${documentId}_${chunkId}`);

      try {
        await this.vectorService.deleteDocumentVectorsByIds({
          userId,
          ids: vectorIds,
        });
        logger.info("Vectors deleted successfully during cancellation", {
          documentId,
          userId,
          vectorCount: vectorIds.length,
        });
      } catch (error) {
        logger.warn("Pinecone vector deletion failed during cancellation", {
          documentId,
          userId,
          error: error instanceof Error ? error.message : String(error),
        });
        // Continue with cleanup even if vector deletion fails
      }
    }

    // Step 2: Delete Firestore chunks
    try {
      await this.deleteChunkSubcollection(docRef, documentId, chunkIds);
      logger.info("Chunks deleted successfully during cancellation", {
        documentId,
        userId,
        chunkCount: chunkIds.length,
      });
    } catch (error) {
      logger.warn("Chunk deletion failed during cancellation", {
        documentId,
        userId,
        error: error instanceof Error ? error.message : String(error),
      });
    }

    // Step 3: Delete storage object
    if (document.storagePath) {
      try {
        await deleteFromStorage(document.storagePath);
        logger.info("Storage object deleted successfully during cancellation", {
          documentId,
          userId,
          storagePath: document.storagePath,
        });
      } catch (error) {
        logger.warn("Storage deletion failed during cancellation", {
          documentId,
          userId,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    // Step 4: Delete Firestore document last
    await docRef.delete();

    logger.info("Document cancelled and cleaned up", {
      documentId,
      userId,
      chunkCount: chunkIds.length,
    });

    return { documentId, cancelled: true };
  }

  /**
   * Trigger text extraction for uploaded document (Story 3.4 integration)
   * AC1, AC3: Background processing trigger
   *
   * @param documentId - Document ID to process
   */
  private async triggerTextExtraction(documentId: string): Promise<void> {
    try {
      const initialSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!initialSnapshot.exists) {
        logger.info("Skipping processing - document missing", { documentId });
        return;
      }

      const initialDocument = initialSnapshot.data() as Document | undefined;

      if (initialDocument?.cancelRequestedAt) {
        logger.info("Skipping processing - cancellation requested", {
          documentId,
          userId: initialDocument.userId,
        });
        return;
      }

      const extractedText =
        await this.embeddingService.extractTextFromDocument(documentId);

      const docSnap = await this.db
        .collection("documents")
        .doc(documentId)
        .get();
      if (!docSnap.exists) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      const document = docSnap.data();
      if (!document?.userId) {
        throw new AppError("INVALID_DOCUMENT", "Document userId missing", 400);
      }

      if (document.cancelRequestedAt) {
        logger.info("Stopping processing - cancellation requested", {
          documentId,
          userId: document.userId,
        });
        return;
      }

      const chunkedDocument = await this.embeddingService.chunkDocumentText(
        extractedText,
        documentId,
        document.userId,
      );

      await this.persistChunks(
        documentId,
        document.userId,
        chunkedDocument.chunks,
      );

      const postChunkSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!postChunkSnapshot.exists) {
        logger.info("Stopping processing - document removed", { documentId });
        return;
      }

      const postChunkDocument = postChunkSnapshot.data() as
        | Document
        | undefined;
      if (postChunkDocument?.cancelRequestedAt) {
        logger.info("Stopping processing - cancellation requested", {
          documentId,
          userId: postChunkDocument.userId,
        });
        return;
      }

      const embeddingInputs: EmbeddingInputChunk[] = chunkedDocument.chunks.map(
        (chunk) => ({
          text: chunk.text,
          metadata: {
            pageNumber: chunk.pageNumber,
            chunkIndex: chunk.chunkIndex,
            textPreview: chunk.textPreview,
          },
        }),
      );

      // Check for cancellation before embedding generation
      const preEmbeddingSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!preEmbeddingSnapshot.exists) {
        logger.info("Stopping processing - document removed before embedding", {
          documentId,
        });
        return;
      }

      const preEmbeddingDoc = preEmbeddingSnapshot.data() as
        | Document
        | undefined;
      if (preEmbeddingDoc?.cancelRequestedAt) {
        logger.info(
          "Stopping processing - cancellation requested before embedding",
          {
            documentId,
            userId: preEmbeddingDoc.userId,
          },
        );
        return;
      }

      const embeddings =
        await this.embeddingService.generateEmbeddings(embeddingInputs);

      // Validate embedding count matches chunk count before indexing
      if (embeddings.length !== chunkedDocument.chunks.length) {
        throw new ValidationError(
          "Embedding count mismatch: vectorCount would not match chunk count",
          {
            documentId,
            chunkCount: chunkedDocument.chunks.length,
            embeddingCount: embeddings.length,
          },
        );
      }

      // Final cancellation check before vector storage
      const preVectorSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!preVectorSnapshot.exists) {
        logger.info(
          "Stopping processing - document removed before vector storage",
          {
            documentId,
          },
        );
        return;
      }

      const preVectorDoc = preVectorSnapshot.data() as Document | undefined;
      if (preVectorDoc?.cancelRequestedAt) {
        logger.info(
          "Stopping processing - cancellation requested before vector storage",
          {
            documentId,
            userId: preVectorDoc.userId,
          },
        );
        return;
      }

      await this.vectorService.upsertDocumentEmbeddings({
        userId: document.userId,
        documentId,
        embeddings,
      });

      // Final check before marking as ready
      const finalSnapshot = await this.db
        .collection("documents")
        .doc(documentId)
        .get();

      if (!finalSnapshot.exists || finalSnapshot.data()?.cancelRequestedAt) {
        logger.info("Document cancelled after processing completed", {
          documentId,
        });
        return;
      }

      await this.db.collection("documents").doc(documentId).update({
        status: "ready",
        vectorCount: embeddings.length,
        indexedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      logger.info("Embeddings generated for document", {
        documentId,
        userId: document.userId,
        chunkCount: embeddings.length,
      });
    } catch (error) {
      if (error instanceof AppError && error.code === "DOCUMENT_NOT_FOUND") {
        logger.info("Processing stopped - document missing", {
          documentId,
          error: error.message,
        });
        return;
      }

      logger.error("Document processing failed", {
        documentId,
        error: error instanceof Error ? error.message : String(error),
      });

      try {
        await this.db
          .collection("documents")
          .doc(documentId)
          .update({
            status: "error",
            errorMessage:
              error instanceof Error
                ? error.message
                : "Document processing failed. Please try again later.",
            updatedAt: FieldValue.serverTimestamp(),
          });
      } catch (updateError) {
        logger.error("Failed to update document error status", {
          documentId,
          originalError: error instanceof Error ? error.message : String(error),
          statusUpdateError:
            updateError instanceof Error
              ? updateError.message
              : String(updateError),
        });
      }
    }
  }

  private async persistChunks(
    documentId: string,
    userId: string,
    chunks: {
      text: string;
      pageNumber: number;
      chunkIndex: number;
      textPreview: string;
    }[],
  ): Promise<void> {
    if (!chunks || chunks.length === 0) {
      throw new ValidationError("No chunks available for persistence", {
        documentId,
      });
    }

    const batches = this.chunkIntoBatches(chunks, 500);

    for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      const batch = batches[batchIndex];
      const writeBatch = this.db.batch();

      for (const chunk of batch) {
        const chunkRef = this.db
          .collection("documents")
          .doc(documentId)
          .collection("chunks")
          .doc(String(chunk.chunkIndex));

        writeBatch.set(chunkRef, {
          userId,
          documentId,
          chunkIndex: chunk.chunkIndex,
          pageNumber: chunk.pageNumber,
          text: chunk.text,
          textPreview:
            chunk.textPreview.length > 200
              ? chunk.textPreview.substring(0, 200)
              : chunk.textPreview,
          createdAt: FieldValue.serverTimestamp(),
        });
      }

      await writeBatch.commit();

      logger.info("Document chunks persisted", {
        userId,
        documentId,
        batchIndex,
        batchSize: batch.length,
      });
    }
  }

  private async fetchChunkIds(
    docRef: DocumentReference,
    documentId: string,
  ): Promise<string[]> {
    const chunksSnapshot = await docRef.collection("chunks").get();

    logger.info("Fetched document chunks for cancellation", {
      documentId,
      chunkCount: chunksSnapshot.docs.length,
    });

    return chunksSnapshot.docs.map((doc) => doc.id);
  }

  private async deleteChunkSubcollection(
    docRef: DocumentReference,
    documentId: string,
    chunkIds: string[],
  ): Promise<void> {
    if (!chunkIds || chunkIds.length === 0) {
      return;
    }

    const batches = this.chunkIntoBatches(chunkIds, 500);

    for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      const batch = batches[batchIndex];
      const writeBatch = this.db.batch();

      for (const chunkId of batch) {
        const chunkRef = docRef.collection("chunks").doc(chunkId);
        writeBatch.delete(chunkRef);
      }

      await writeBatch.commit();

      logger.info("Deleted document chunk batch", {
        documentId,
        batchIndex,
        batchSize: batch.length,
      });
    }
  }

  private chunkIntoBatches<T>(items: T[], size: number): T[][] {
    const batches: T[][] = [];
    for (let i = 0; i < items.length; i += size) {
      batches.push(items.slice(i, i + size));
    }
    return batches;
  }
}
