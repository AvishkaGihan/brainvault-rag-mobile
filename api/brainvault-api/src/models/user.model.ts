import { firestore } from "firebase-admin";
import { db } from "../config/firebase";
import { User, UserSettings } from "../types/user.types";

export class UserModel {
  /**
   * Converts a Firestore snapshot to a User entity.
   */
  static fromFirestore(snapshot: firestore.DocumentSnapshot): User | null {
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
      email: data.email,
      displayName: data.displayName,
      createdAt: toDate(data.createdAt),
      updatedAt: toDate(data.updatedAt),
      isGuest: data.isGuest ?? false,
      documentCount: data.documentCount ?? 0,
      storageUsage: data.storageUsage ?? 0,
      settings: (data.settings as UserSettings) || {
        theme: "system",
        language: "en",
      },
    };
  }

  /**
   * Converts a partial User entity to Firestore format.
   */
  static toFirestore(data: Partial<User>): Record<string, any> {
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
   * Reference to the users collection.
   */
  private static getCollectionRef(): firestore.CollectionReference {
    return db.collection("users");
  }

  // ------------------------------------------------------------------
  // User Management
  // ------------------------------------------------------------------

  /**
   * Retrieves a user by their Firebase Auth UID.
   */
  static async findById(userId: string): Promise<User | null> {
    const docRef = this.getCollectionRef().doc(userId);
    const snapshot = await docRef.get();
    return this.fromFirestore(snapshot);
  }

  /**
   * Creates a new user document if it doesn't exist.
   * Typically called by auth middleware or on first login.
   */
  static async createUser(
    user: Omit<User, "createdAt" | "updatedAt" | "documentCount">
  ): Promise<User> {
    const docRef = this.getCollectionRef().doc(user.id);

    // Check if exists first to avoid overwriting existing data
    const existing = await docRef.get();
    if (existing.exists) {
      return this.fromFirestore(existing)!;
    }

    const userData = {
      ...user,
      createdAt: new Date(),
      updatedAt: new Date(),
      documentCount: 0,
      settings: user.settings || { theme: "system" },
    };

    await docRef.set(this.toFirestore(userData));

    const snapshot = await docRef.get();
    const created = this.fromFirestore(snapshot);

    if (!created) {
      throw new Error("Failed to create user document");
    }

    return created;
  }

  /**
   * Updates user profile fields or settings.
   */
  static async update(userId: string, updates: Partial<User>): Promise<void> {
    const docRef = this.getCollectionRef().doc(userId);

    const updateData = this.toFirestore({
      ...updates,
      updatedAt: new Date(),
    });

    await docRef.update(updateData);
  }

  // ------------------------------------------------------------------
  // Helper Methods
  // ------------------------------------------------------------------

  /**
   * Atomically increments or decrements the denormalized document count.
   * Used when documents are added or deleted.
   */
  static async updateDocumentCount(
    userId: string,
    change: number
  ): Promise<void> {
    const docRef = this.getCollectionRef().doc(userId);

    await docRef.update({
      documentCount: firestore.FieldValue.increment(change),
      updatedAt: firestore.Timestamp.now(),
    });
  }
}
