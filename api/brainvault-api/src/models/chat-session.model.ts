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
}
