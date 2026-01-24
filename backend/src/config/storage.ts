import { getStorage, Storage } from "firebase-admin/storage";
import * as admin from "firebase-admin";

let storageInstance: Storage | null = null;

/**
 * Get Firebase Storage instance (singleton)
 * AC1, AC6: Firebase Storage integration for document uploads
 */
export function getStorageInstance(): Storage {
  if (!storageInstance) {
    storageInstance = getStorage(admin.app());
  }
  return storageInstance;
}

/**
 * Generate unique storage path for user's document
 * AC6: User isolation - path includes userId
 * Pattern: users/{userId}/documents/{documentId}.pdf
 *
 * @param userId - User's Firebase UID
 * @param documentId - Unique document identifier
 * @returns Storage path string
 */
export function generateStoragePath(
  userId: string,
  documentId: string,
): string {
  return `users/${userId}/documents/${documentId}.pdf`;
}

/**
 * Upload file buffer to Firebase Storage
 * AC1: File upload to Firebase Storage
 *
 * @param buffer - File buffer to upload
 * @param storagePath - Destination path in Storage
 * @param contentType - MIME type of the file
 * @returns Storage path of uploaded file
 */
export async function uploadToStorage(
  buffer: Buffer,
  storagePath: string,
  contentType: string = "application/pdf",
): Promise<string> {
  const bucket = getStorageInstance().bucket();
  const file = bucket.file(storagePath);

  await file.save(buffer, {
    contentType,
    metadata: {
      uploadedAt: new Date().toISOString(),
    },
  });

  // Return the storage path (not public URL for security)
  return storagePath;
}

/**
 * Delete file from Storage (cleanup on error)
 * AC8: Error recovery and cleanup
 *
 * @param storagePath - Path to file in Storage
 */
export async function deleteFromStorage(storagePath: string): Promise<void> {
  try {
    const bucket = getStorageInstance().bucket();
    const file = bucket.file(storagePath);
    await file.delete();
  } catch (error) {
    // Log error but don't throw (cleanup is best-effort)
    console.error(`Failed to delete file from Storage: ${storagePath}`, error);
  }
}
