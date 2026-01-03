import { firestore } from "firebase-admin";
import { db } from "../config/firebase";
import { ChatSession } from "../types/chat.types";

export class ChatSessionModel {
  /**
   * Converts a Firestore snapshot to a ChatSession entity.
   */
  static fromFirestore(
    snapshot: firestore.DocumentSnapshot
  ): ChatSession | null {
    if (!snapshot.exists) return null;

    const data = snapshot.data();
    if (!data) return null;

    // Helper to safely convert Firestore Timestamp to JS Date
    const toDate = (ts: any): Date => {
      if (ts instanceof firestore.Timestamp) {
        return ts.toDate();
      }
      return new Date();
    };

    return {
      id: snapshot.id,
      documentId: data.documentId,
      userId: data.userId,
      createdAt: toDate(data.createdAt),
      updatedAt: toDate(data.updatedAt),
      messageCount: data.messageCount ?? 0,
    };
  }

  /**
   * Converts a partial ChatSession entity to Firestore format.
   */
  static toFirestore(data: Partial<ChatSession>): Record<string, any> {
    const firestoreData: Record<string, any> = { ...data };

    // Remove id as it's the document key
    delete firestoreData.id;

    // Convert Dates to Timestamps
    if (data.createdAt instanceof Date) {
      firestoreData.createdAt = firestore.Timestamp.fromDate(data.createdAt);
    }

    // Always handle updatedAt
    if (data.updatedAt instanceof Date) {
      firestoreData.updatedAt = firestore.Timestamp.fromDate(data.updatedAt);
    } else {
      firestoreData.updatedAt = firestore.Timestamp.now();
    }

    return firestoreData;
  }

  /**
   * Helper to construct the collection path.
   * Path: /users/{userId}/documents/{documentId}/chats
   */
  private static getCollectionRef(
    userId: string,
    documentId: string
  ): firestore.CollectionReference {
    return db
      .collection("users")
      .doc(userId)
      .collection("documents")
      .doc(documentId)
      .collection("chats");
  }

  // ---------------------------------------------------------------------------------
  // CRUD Operations
  // ---------------------------------------------------------------------------------

  /**
   * Creates a new chat session.
   * Typically initialized when a user starts chatting about a document.
   */
  static async createSession(
    userId: string,
    documentId: string,
    sessionId?: string
  ): Promise<ChatSession> {
    const collectionRef = this.getCollectionRef(userId, documentId);
    const docRef = sessionId
      ? collectionRef.doc(sessionId)
      : collectionRef.doc();

    const sessionData = {
      documentId,
      userId,
      createdAt: new Date(),
      updatedAt: new Date(),
      messageCount: 0,
    };

    await docRef.set(this.toFirestore(sessionData));

    const snapshot = await docRef.get();
    const created = this.fromFirestore(snapshot);

    return created!;
  }

  /**
   * Retrieves a specific chat session.
   */
  static async findById(
    userId: string,
    documentId: string,
    sessionId: string
  ): Promise<ChatSession | null> {
    const docRef = this.getCollectionRef(userId, documentId).doc(sessionId);
    const snapshot = await docRef.get();
    return this.fromFirestore(snapshot);
  }
}
