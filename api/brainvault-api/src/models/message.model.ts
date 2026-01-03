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

  /**
   * Helper to construct the deeply nested collection path.
   * Path: /users/{userId}/documents/{documentId}/chats/{chatId}/messages
   */
  private static getCollectionRef(
    userId: string,
    documentId: string,
    chatId: string
  ): firestore.CollectionReference {
    return db
      .collection("users")
      .doc(userId)
      .collection("documents")
      .doc(documentId)
      .collection("chats")
      .doc(chatId)
      .collection("messages");
  }

  // -----------------------------------------------------------------------------
  // CRUD Operations
  // -----------------------------------------------------------------------------

  /**
   * Create a new message in a chat session.
   */
  static async create(
    userId: string,
    documentId: string,
    chatId: string,
    message: Omit<Message, "id" | "createdAt"> & { id?: string }
  ): Promise<Message> {
    const collectionRef = this.getCollectionRef(userId, documentId, chatId);
    const docRef = message.id
      ? collectionRef.doc(message.id)
      : collectionRef.doc();

    const messageData = {
      ...message,
      chatId, // Ensure chatId matches parent
      createdAt: new Date(),
    };

    await docRef.set(this.toFirestore(messageData));

    const snapshot = await docRef.get();
    const created = this.fromFirestore(snapshot);

    if (!created) {
      throw new Error("Failed to retrieve created message");
    }

    return created;
  }

  /**
   * List messages for a specific chat session.
   * Ordered by creation time ascending (for chat history display).
   */
  static async list(
    userId: string,
    documentId: string,
    chatId: string
  ): Promise<Message[]> {
    const collectionRef = this.getCollectionRef(userId, documentId, chatId);

    // Order by createdAt ascending so the conversation flows naturally
    const snapshot = await collectionRef.orderBy("createdAt", "asc").get();

    return snapshot.docs
      .map((doc) => this.fromFirestore(doc))
      .filter((msg): msg is Message => msg !== null);
  }
}
