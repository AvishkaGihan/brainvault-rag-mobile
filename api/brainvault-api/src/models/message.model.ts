import { firestore } from "firebase-admin";
import { db } from "../config/firebase";
import { Message, MessageRole, Citation } from "../types/chat.types";

export class MessageModel {
  /**
   * Converts a Firestore snapshot to a Message entity.
   */
  static fromFirestore(snapshot: firestore.DocumentSnapshot): Message | null {
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
      chatId: data.chatId,
      role: data.role as MessageRole,
      content: data.content,
      citations: (data.citations || []) as Citation[],
      createdAt: toDate(data.createdAt),
      isError: data.isError,
      errorMessage: data.errorMessage,
    };
  }

  /**
   * Converts a Message entity to Firestore format.
   */
  static toFirestore(data: Partial<Message>): Record<string, any> {
    const firestoreData: Record<string, any> = { ...data };

    // Remove id as it's the document key
    delete firestoreData.id;

    // Convert Date to Timestamp
    if (data.createdAt instanceof Date) {
      firestoreData.createdAt = firestore.Timestamp.fromDate(data.createdAt);
    } else {
      firestoreData.createdAt = firestore.Timestamp.now();
    }

    // Ensure citations is an array (empty if undefined)
    firestoreData.citations = data.citations || [];

    return firestoreData;
  }
}
