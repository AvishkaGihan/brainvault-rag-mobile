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

  /**
   * Converts a partial or full Document entity to Firestore format.
   * Ensures timestamps are handled correctly (using ServerValue for updates if needed,
   * but usually explicit Dates are passed from Service layer or created here).
   */
  static toFirestore(data: Partial<Document>): Record<string, any> {
    const firestoreData: Record<string, any> = { ...data };

    // Remove id as it's the document key
    delete firestoreData.id;

    // Convert Dates to Timestamps
    if (data.createdAt instanceof Date) {
      firestoreData.createdAt = firestore.Timestamp.fromDate(data.createdAt);
    }

    // Always update updatedAt to now if not explicitly provided,
    // or ensure provided Date is converted.
    // Ideally, the Service layer controls business logic, but Model ensures correctness.
    if (data.updatedAt instanceof Date) {
      firestoreData.updatedAt = firestore.Timestamp.fromDate(data.updatedAt);
    } else {
      firestoreData.updatedAt = firestore.Timestamp.now();
    }

    return firestoreData;
  }

  /**
   * Reference to the user's documents collection.
   * Enforces the path structure: /users/{userId}/documents
   */
  private static getCollectionRef(
    userId: string
  ): firestore.CollectionReference {
    return db.collection("users").doc(userId).collection("documents");
  }

  // ------------------------------------------------------------------
  // CRUD Operations
  // ------------------------------------------------------------------

  /**
   * Create a new document in Firestore.
   */
  static async create(
    document: Omit<Document, "id"> & { id?: string }
  ): Promise<Document> {
    const { userId, id } = document;

    // Ensure vectorNamespace follows strict format
    const docData = {
      ...document,
      vectorNamespace: `user_${userId}`,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const collectionRef = this.getCollectionRef(userId);
    const docRef = id ? collectionRef.doc(id) : collectionRef.doc();

    await docRef.set(this.toFirestore(docData));

    const snapshot = await docRef.get();
    const created = this.fromFirestore(snapshot);

    if (!created) {
      throw new Error("Failed to retrieve created document");
    }

    return created;
  }
}
