import { AppError } from "../types/api.types";

/**
 * Validate PDF file header
 * AC2: PDF validation - check for valid PDF signature
 *
 * @param buffer - File buffer to validate
 * @returns true if valid PDF header, false otherwise
 */
export function validatePDFHeader(buffer: Buffer): boolean {
  // PDF files MUST start with "%PDF-" signature
  const pdfHeader = buffer.subarray(0, 5).toString("ascii");
  return pdfHeader === "%PDF-";
}

/**
 * Validate PDF content and structure
 * AC2: PDF validation with detailed error messages
 *
 * @param buffer - File buffer to validate
 * @throws AppError if PDF is invalid or corrupt
 */
export function validatePDFContent(buffer: Buffer): void {
  if (!validatePDFHeader(buffer)) {
    throw new AppError(
      "INVALID_PDF_FILE",
      "The PDF file appears to be corrupted or invalid",
      400,
      { reason: "Missing PDF header" },
    );
  }

  // Optional: Additional validation with pdf-parse can be added here
  // For now, header check is sufficient per story requirements
  // Full PDF parsing will be implemented in Story 3.4
}

/**
 * Validate text document input
 * AC4: Text content validation with specific error messages
 *
 * @param title - Document title to validate
 * @param content - Text content to validate
 * @throws AppError with specific validation error
 */
export function validateTextDocument(title: string, content: string): void {
  // Title validation
  if (!title || title.trim().length === 0) {
    throw new AppError("INVALID_TITLE", "Title must not be empty", 400, {
      titleLength: 0,
      minLength: 1,
    });
  }

  if (title.length > 100) {
    throw new AppError(
      "INVALID_TITLE",
      "Title must be between 1 and 100 characters",
      400,
      { titleLength: title.length, maxLength: 100 },
    );
  }

  // Content validation
  if (!content || content.trim().length < 10) {
    throw new AppError(
      "TEXT_TOO_SHORT",
      "Text content must be at least 10 characters",
      400,
      { contentLength: content.trim().length, minLength: 10 },
    );
  }

  if (content.length > 50000) {
    throw new AppError(
      "TEXT_TOO_LONG",
      "Text content exceeds maximum length of 50,000 characters",
      400,
      { contentLength: content.length, maxLength: 50000 },
    );
  }
}
