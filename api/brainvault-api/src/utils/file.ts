import { unlink } from "fs/promises";
import { v4 as uuidv4 } from "uuid";
import path from "path";

/**
 * Maximum file size in bytes (5 MB).
 * Matches constraints in mobile app and architecture docs.
 */
export const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024;

/**
 * Result of a file validation check.
 */
export interface ValidationResult {
  valid: boolean;
  error?: string;
}

/**
 * Validates an uploaded file to ensure it matches PDF requirements.
 * Enforces MIME type 'application/pdf' and maximum size of 5MB.
 * @param file - The Multer file object to validate
 * @returns ValidationResult indicating success or failure with reason
 */
export function validatePdfFile(file: Express.Multer.File): ValidationResult {
  if (!file) {
    return { valid: false, error: "No file provided" };
  }

  // 1. Check MIME type
  if (file.mimetype !== "application/pdf") {
    return {
      valid: false,
      error: `Invalid file type: ${file.mimetype}. Only PDF files are allowed.`,
    };
  }

  // 2. Check File Size
  if (file.size > MAX_FILE_SIZE_BYTES) {
    const sizeMB = getFileSizeInMB(file.size);
    return {
      valid: false,
      error: `File too large (${sizeMB} MB). Maximum allowed size is 5 MB.`,
    };
  }

  return { valid: true };
}

/**
 * Converts bytes to a human-readable MB string with 2 decimal places.
 * @param bytes - Size in bytes
 * @returns String representation in MB (e.g., "4.20")
 */
export function getFileSizeInMB(bytes: number): string {
  return (bytes / (1024 * 1024)).toFixed(2);
}

/**
 * Safely deletes a temporary file from the disk.
 * Non-blocking operation that logs errors but doesn't throw (fire-and-forget safe).
 * @param filePath - Absolute path to the file
 */
export async function cleanupTempFile(filePath: string): Promise<void> {
  if (!filePath) return;

  try {
    await unlink(filePath);
  } catch (error) {
    // We log but don't throw, as cleanup failure shouldn't fail the user request
    console.warn(`Failed to delete temp file at ${filePath}:`, error);
  }
}

/**
 * Generates a safe, randomized filename while preserving the original extension.
 * Prevents directory traversal attacks and filename collisions.
 * @param originalName - The original filename uploaded by the user
 * @returns A safe filename string (UUID + .pdf)
 */
export function sanitizeFilename(originalName: string): string {
  const ext = path.extname(originalName).toLowerCase() || ".pdf";
  // Use UUID to guarantee uniqueness and safety
  return `${uuidv4()}${ext}`;
}
