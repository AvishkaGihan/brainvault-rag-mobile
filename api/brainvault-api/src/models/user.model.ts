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
      settings: (data.settings as UserSettings) || { theme: "system" },
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
}
