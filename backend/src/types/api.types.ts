/**
 * Standard API Response Types
 * All API endpoints must conform to this structure
 *
 * Based on ARCH-6, ARCH-7: Standard API response format
 */

/**
 * Error codes for consistent error handling
 */
export const ERROR_CODES = {
  INTERNAL_SERVER_ERROR: "INTERNAL_SERVER_ERROR",
  BAD_REQUEST: "BAD_REQUEST",
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  NOT_FOUND: "NOT_FOUND",
  VALIDATION_ERROR: "VALIDATION_ERROR",
  CONFIGURATION_ERROR: "CONFIGURATION_ERROR",
  RATE_LIMIT_EXCEEDED: "RATE_LIMIT_EXCEEDED",
  INVALID_FILE_TYPE: "INVALID_FILE_TYPE",
  NO_FILE_PROVIDED: "NO_FILE_PROVIDED",
  INVALID_PDF_FILE: "INVALID_PDF_FILE",
  UPLOAD_FAILED: "UPLOAD_FAILED",
  INVALID_TITLE: "INVALID_TITLE",
  TEXT_TOO_SHORT: "TEXT_TOO_SHORT",
  TEXT_TOO_LONG: "TEXT_TOO_LONG",
  MISSING_FIELDS: "MISSING_FIELDS",
  FILE_TOO_LARGE: "FILE_TOO_LARGE",
  FILE_UPLOAD_ERROR: "FILE_UPLOAD_ERROR",
  DOCUMENT_NOT_FOUND: "DOCUMENT_NOT_FOUND",
  INVALID_DOCUMENT: "INVALID_DOCUMENT",
  PDF_EXTRACTION_FAILED: "PDF_EXTRACTION_FAILED",
  DOCUMENT_ACCESS_FAILED: "DOCUMENT_ACCESS_FAILED",
} as const;

/**
 * Standard error response structure
 */
export interface ApiError {
  code: (typeof ERROR_CODES)[keyof typeof ERROR_CODES];
  message: string;
  details?: Record<string, unknown>;
}

/**
 * Standard API response wrapper
 * All endpoints return this format
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta: {
    timestamp: string;
    count?: number;
  };
}

/**
 * Health check response data
 */
export interface HealthCheckData {
  status: "ok";
  uptime: number;
  timestamp: string;
}

/**
 * Custom error class for API errors with structured error response format
 */
export class AppError extends Error {
  constructor(
    public code: (typeof ERROR_CODES)[keyof typeof ERROR_CODES],
    public message: string,
    public statusCode: number = 500,
    public details: Record<string, any> = {},
  ) {
    super(message);
    this.name = "AppError";
    Error.captureStackTrace(this, this.constructor);
  }

  /**
   * Convert to API error response format
   */
  toJSON() {
    return {
      success: false,
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
      },
    };
  }
}
