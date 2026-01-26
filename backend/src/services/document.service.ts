import { getFirestore, FieldValue } from "firebase-admin/firestore";
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
   * Trigger text extraction for uploaded document (Story 3.4 integration)
   * AC1, AC3: Background processing trigger
   *
   * @param documentId - Document ID to process
   */
  private async triggerTextExtraction(documentId: string): Promise<void> {
    try {
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

      await this.vectorService.upsertDocumentEmbeddings({
        userId: document.userId,
        documentId,
        embeddings,
      });

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

  private chunkIntoBatches<T>(items: T[], size: number): T[][] {
    const batches: T[][] = [];
    for (let i = 0; i < items.length; i += size) {
      batches.push(items.slice(i, i + size));
    }
    return batches;
  }
}
