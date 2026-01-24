import multer, { FileFilterCallback } from "multer";
import { Request, Response, NextFunction } from "express";
import { AppError } from "../types";

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB in bytes (5,242,880)

/**
 * Multer configuration for PDF uploads
 * AC1: Multipart form-data handling with validation
 * Stores files in memory temporarily for validation before Storage upload
 */
export const upload = multer({
  storage: multer.memoryStorage(), // Store in memory, not disk
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1, // Only one file per request
  },
  fileFilter: (
    req: Request,
    file: Express.Multer.File,
    callback: FileFilterCallback,
  ) => {
    // MIME type check (first layer of defense)
    // AC2: File validation - MIME type must be application/pdf
    if (file.mimetype !== "application/pdf") {
      return callback(
        new AppError("INVALID_FILE_TYPE", "Only PDF files are supported", 400, {
          receivedType: file.mimetype,
          supportedTypes: ["application/pdf"],
        }) as any,
      );
    }

    callback(null, true);
  },
});

/**
 * Multer error handler middleware
 * AC2: Transform Multer-specific errors into AppError format
 */
export function handleMulterError(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return next(
        new AppError(
          "FILE_TOO_LARGE",
          "File exceeds maximum size of 5MB",
          400,
          { maxSize: MAX_FILE_SIZE },
        ),
      );
    }
    return next(new AppError("FILE_UPLOAD_ERROR", err.message, 400));
  }
  next(err);
}
