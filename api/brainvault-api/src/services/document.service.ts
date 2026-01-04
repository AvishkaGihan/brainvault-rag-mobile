import { db as firestore, storage } from "../config/firebase";
import { getIndex } from "../config/pinecone";
import { Document, DocumentStatus } from "../types/document.types";
import { DocumentModel } from "../models/document.model";
import { userService } from "./user.service";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";

export class DocumentService {
  private collection = "documents";

  /**

* Creates a new document record in Firestore with initial 'uploading' status.
* Updates the user's document count.
*/
  async createDocument(
    userId: string,
    name: string,
    fileSize: number,
    storagePath: string
  ): Promise<Document> {
    try {
      const newDoc: Document = {
        id: firestore.collection(this.collection).doc().id, // Generate ID client-side style for ref
        userId,
        name,
        storagePath,
        fileSize,
        mimeType: "application/pdf", // MVP restricted to PDF
        status: "uploading",
        processingProgress: 0,
        processingStage: "uploading",
        pageCount: 0,
        chunkCount: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      const docData = DocumentModel.toFirestore(newDoc);
      // Use a batch or run strictly sequential to ensure count consistency
      await firestore.collection(this.collection).doc(newDoc.id).set(docData);
      // Update user stats
      await userService.incrementDocumentCount(userId, 1);
      logger.info(`Created document metadata for ${newDoc.id}`);
      return newDoc;
    } catch (error) {
      logger.error("Error creating document:", error);
      throw new AppError(500, "Failed to create document record");
    }
  }

  /**

* Retrieves a document by ID and verifies ownership.
*/
  async getDocument(documentId: string, userId: string): Promise<Document> {
    try {
      const docRef = firestore.collection(this.collection).doc(documentId);
      const docSnap = await docRef.get();
      if (!docSnap.exists) {
        throw new AppError(404, "Document not found");
      }
      const document = DocumentModel.fromFirestore(docSnap);
      if (!document) {
        throw new AppError(404, "Document not found");
      }
      if (document.userId !== userId) {
        throw new AppError(403, "Unauthorized access to document");
      }
      return document;
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Error fetching document ${documentId}`, error);
      throw new AppError(500, "Failed to retrieve document");
    }
  }

  /**

* Lists all documents for a specific user, ordered by creation date (newest first).
*/
  async listDocuments(userId: string): Promise<Document[]> {
    try {
      const snapshot = await firestore
        .collection(this.collection)
        .where("userId", "==", userId)
        .orderBy("createdAt", "desc")
        .get();
      return snapshot.docs
        .map((doc) => DocumentModel.fromFirestore(doc))
        .filter((doc): doc is Document => doc !== null);
    } catch (error) {
      logger.error(`Error listing documents for user ${userId}`, error);
      throw new AppError(500, "Failed to list documents");
    }
  }

  /**

* Updates the processing status, progress percentage, and current stage description.
* Used by the IngestionService to report progress to the UI.
*/
  async updateStatus(
    documentId: string,
    status: DocumentStatus,
    processingProgress: number,
    processingStage: string,
    errorMessage?: string
  ): Promise<void> {
    try {
      const updates: any = {
        status,
        processingProgress,
        processingStage,
        updatedAt: new Date(),
      };
      if (errorMessage) {
        updates.errorMessage = errorMessage;
      }
      await firestore
        .collection(this.collection)
        .doc(documentId)
        .update(updates);
      logger.debug(
        `Updated status for ${documentId}: ${status} (${processingProgress}%)`
      );
    } catch (error) {
      logger.error(`Failed to update status for document ${documentId}`, error);
      throw new AppError(500, "Failed to update document status");
    }
  }

  /**

* Helper to find documents in a specific state (e.g., stuck in processing).
*/
  async getDocumentsByStatus(
    userId: string,
    status: DocumentStatus
  ): Promise<Document[]> {
    try {
      const snapshot = await firestore
        .collection(this.collection)
        .where("userId", "==", userId)
        .where("status", "==", status)
        .get();
      return snapshot.docs
        .map((doc) => DocumentModel.fromFirestore(doc))
        .filter((doc): doc is Document => doc !== null);
    } catch (error) {
      logger.error(`Error fetching documents by status ${status}`, error);
      throw new AppError(500, "Failed to fetch documents by status");
    }
  }

  /**

* Deletes a document and performs full cleanup:
* 1. Firestore metadata


* 2. Firebase Storage file


* 3. Pinecone vector embeddings


* 4. Updates User document count
*/
  async deleteDocument(documentId: string, userId: string): Promise<void> {
    logger.info(`Starting deletion for document ${documentId}`);

    // 1. Get document details first to verify owner and get storage path
    let document: Document;
    try {
      document = await this.getDocument(documentId, userId);
    } catch (error) {
      // If document doesn't exist in Firestore, we can't proceed with full cleanup safely
      // or it's already gone.
      if (error instanceof AppError && error.statusCode === 404) {
        logger.warn(
          `Document ${documentId} not found during delete request, skipping.`
        );
        return;
      }
      throw error;
    }

    try {
      // 2. Delete from Pinecone
      // We delete all vectors where metadata.documentId matches
      const index = getIndex();
      const namespace = `user_${userId}`;

      try {
        await index.namespace(namespace).deleteMany({
          documentId: { $eq: documentId },
        });
        logger.info(`Deleted vectors for document ${documentId}`);
      } catch (pineconeError) {
        logger.error(
          `Failed to delete vectors for ${documentId}`,
          pineconeError
        );
        // Continue cleanup even if Pinecone fails (prevent zombie files)
      }

      // 3. Delete from Firebase Storage
      if (document.storagePath) {
        try {
          const file = storage.bucket().file(document.storagePath);
          await file.delete();
          logger.info(`Deleted storage file: ${document.storagePath}`);
        } catch (storageError: any) {
          if (storageError.code !== 404) {
            logger.error(
              `Failed to delete file from storage: ${document.storagePath}`,
              storageError
            );
            // Continue
          }
        }
      }

      // 4. Delete from Firestore
      await firestore.collection(this.collection).doc(documentId).delete();

      // 5. Decrement user document count
      await userService.incrementDocumentCount(userId, -1);

      logger.info(`Successfully deleted document ${documentId}`);
    } catch (error) {
      logger.error(`Critical error deleting document ${documentId}`, error);
      throw new AppError(500, "Failed to delete document and associated data");
    }
  }
}

export const documentService = new DocumentService();
