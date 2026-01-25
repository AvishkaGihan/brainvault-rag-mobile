import { getFirestore, FieldValue } from "firebase-admin/firestore";
import {
  generateStoragePath,
  uploadToStorage,
  deleteFromStorage,
} from "../config/storage";
import { validatePDFContent, validateTextDocument } from "../utils/validation";
import { AppError } from "../types/api.types";
import type { Document, CreateDocumentDTO } from "../types/document.types";
import type { EmbeddingInputChunk } from "../types/embedding.types";
import { logger } from "../utils/logger";
import { EmbeddingService } from "./embedding.service";

/**
 * Document Service
 * Business logic for document upload and management
 * AC1, AC3, AC6, AC8: Document creation with validation and error recovery
 */
export class DocumentService {
  private db = getFirestore();
  private embeddingService = new EmbeddingService();

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
        console.error("Failed to cleanup Firestore document", deleteError);
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
                : "Document processing failed",
            updatedAt: FieldValue.serverTimestamp(),
          });
      } catch (updateError) {
        logger.error("Failed to update document status", {
          documentId,
          error:
            updateError instanceof Error
              ? updateError.message
              : String(updateError),
        });
      }
    }
  }
}
