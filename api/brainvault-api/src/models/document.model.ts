import { firestore } from "firebase-admin";
import { db } from "../config/firebase";
import { Document, DocumentStatus } from "../types/document.types";

export class DocumentModel {
  /**
   * Converts a Firestore snapshot to a Document entity.
   * Handles Timestamp to Date conversion.
   */
  static fromFirestore(snapshot: firestore.DocumentSnapshot): Document | null {
    if (!snapshot.exists) return null;

    const data = snapshot.data();
    if (!data) return null;

    // Helper to safely convert Firestore Timestamp to JS Date
    const toDate = (ts: any): Date => {
      if (ts instanceof firestore.Timestamp) {
        return ts.toDate();
      }
      return new Date(); // Fallback for safety, though strictly controlled writes prevent this
    };

    return {
      id: snapshot.id,
      userId: data.userId,
      name: data.name,
      storagePath: data.storagePath,
      fileSize: data.fileSize,
      mimeType: data.mimeType,
      pageCount: data.pageCount,
      status: data.status as DocumentStatus,
      processingProgress: data.processingProgress,
      processingStage: data.processingStage,
      errorMessage: data.errorMessage,
      vectorNamespace: data.vectorNamespace,
      chunkCount: data.chunkCount,
      createdAt: toDate(data.createdAt),
      updatedAt: toDate(data.updatedAt),
    };
  }
}
