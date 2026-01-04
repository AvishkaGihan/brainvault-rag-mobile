import { db as firestore, auth } from "../config/firebase";
import { User, UserSettings } from "../types/user.types";
import { Document } from "../types/document.types";
import { UserModel } from "../models/user.model";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";

import { documentService } from "./document.service";

export class UserService {
  private collection = "users";

  /**
   * Creates a new user in Firestore.
   * Initializes default settings and counters.
   */
  async createUser(
    userId: string,
    email: string,
    isGuest: boolean = false
  ): Promise<User> {
    try {
      const newUser: User = {
        id: userId,
        email,
        isGuest,
        settings: {
          theme: "system",
          language: "en",
        },
        documentCount: 0,
        storageUsage: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      const userData = UserModel.toFirestore(newUser);
      await firestore.collection(this.collection).doc(userId).set(userData);
      logger.info(`Created new user: ${userId} (Guest: ${isGuest})`);
      return newUser;
    } catch (error) {
      logger.error(`Error creating user ${userId}`, error);
      throw new AppError(500, "Failed to create user account");
    }
  }

  /**
   * Retrieves a user by their ID.
   * Returns null if not found.
   */
  async getUser(userId: string): Promise<User | null> {
    try {
      const doc = await firestore.collection(this.collection).doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    } catch (error) {
      logger.error(`Error fetching user ${userId}`, error);
      throw new AppError(500, "Failed to retrieve user");
    }
  }

  /**
   * Updates user profile fields.
   */
  async updateUser(userId: string, updates: Partial<User>): Promise<void> {
    try {
      const docRef = firestore.collection(this.collection).doc(userId);
      const doc = await docRef.get();
      if (!doc.exists) {
        throw new AppError(404, "User not found");
      }
      // Ensure we don't overwrite critical immutable fields if passed by mistake
      delete (updates as any).id;
      delete (updates as any).createdAt;
      await docRef.update({
        ...updates,
        updatedAt: new Date(),
      });
      logger.info(`Updated user profile: ${userId}`);
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Error updating user ${userId}`, error);
      throw new AppError(500, "Failed to update user profile");
    }
  }

  /**
   * Updates user settings (e.g., theme).
   */
  async updateSettings(userId: string, settings: UserSettings): Promise<void> {
    try {
      const docRef = firestore.collection(this.collection).doc(userId);
      // Check existence first
      const doc = await docRef.get();
      if (!doc.exists) {
        throw new AppError(404, "User not found");
      }
      await docRef.update({
        settings: settings,
        updatedAt: new Date(),
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Error updating settings for ${userId}`, error);
      throw new AppError(500, "Failed to update user settings");
    }
  }

  /**
   * Atomically increments or decrements the document count for a user.
   * Uses a Firestore transaction to ensure accuracy.
   */
  async incrementDocumentCount(userId: string, delta: number): Promise<void> {
    const userRef = firestore.collection(this.collection).doc(userId);

    try {
      await firestore.runTransaction(async (transaction: any) => {
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new AppError(404, "User not found for document count update");
        }

        const currentCount = userDoc.data()?.documentCount || 0;
        const newCount = currentCount + delta;

        transaction.update(userRef, {
          documentCount: newCount < 0 ? 0 : newCount, // Prevent negative counts
          updatedAt: new Date(),
        });
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(
        `Failed to increment document count for user ${userId}`,
        error
      );
      throw new AppError(500, "Failed to update user document statistics");
    }
  }

  /**
   * Deletes a user account and cascades the deletion to all associated data:
   * 1. User's documents (Firestore, Storage, Pinecone)
   * 2. User's Chat sessions (Firestore)
   * 3. User's Firestore profile
   * 4. Firebase Auth account
   */
  async deleteUser(userId: string): Promise<void> {
    logger.info(`Starting account deletion for user: ${userId}`);

    try {
      // 1. Cascade Delete Documents
      // We use the DocumentService to ensure proper cleanup of vectors and storage
      const userDocuments = await documentService.listDocuments(userId);

      logger.info(
        `Deleting ${userDocuments.length} documents for user ${userId}`
      );

      // Delete documents in parallel (with concurrency limit ideally, but simple Promise.all for now)
      // We accept that some might fail, but we try to clean as much as possible.
      const deletePromises = userDocuments.map((doc: Document) =>
        documentService.deleteDocument(doc.id, userId).catch((err: any) => {
          logger.error(
            `Failed to delete document ${doc.id} during user deletion`,
            err
          );
        })
      );
      await Promise.all(deletePromises);

      // 2. Cascade Delete Chat Sessions (Direct Firestore cleanup for now)
      // Ideally this would go through ChatService, but for efficiency in this batch op we can query directly
      const chatsQuery = await firestore
        .collection("chats")
        .where("userId", "==", userId)
        .get();
      const batch = firestore.batch();

      chatsQuery.docs.forEach((doc: any) => {
        batch.delete(doc.ref);
      });

      // Commit chat deletion batch
      if (!chatsQuery.empty) {
        await batch.commit();
        logger.info(
          `Deleted ${chatsQuery.size} chat sessions for user ${userId}`
        );
      }

      // 3. Delete User Profile from Firestore
      await firestore.collection(this.collection).doc(userId).delete();

      // 4. Delete from Firebase Auth
      try {
        await auth.deleteUser(userId);
      } catch (authError: any) {
        // If the user is not found in Auth (already deleted), we ignore.
        if (authError.code !== "auth/user-not-found") {
          logger.warn(
            `Failed to delete Firebase Auth user ${userId}`,
            authError
          );
          // We don't throw here to ensure the data cleanup isn't rolled back effectively
        }
      }

      logger.info(`Successfully deleted user account: ${userId}`);
    } catch (error) {
      logger.error(`Critical error deleting user ${userId}`, error);
      throw new AppError(500, "Failed to complete user account deletion");
    }
  }
}

// Export singleton
export const userService = new UserService();
