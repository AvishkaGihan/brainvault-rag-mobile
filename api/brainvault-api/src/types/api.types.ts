/**
 * API Response & Error Types
 * This file defines the standard envelope for all API responses to ensure consistency
 * across the application. It also establishes the canonical error codes used
 * by both backend and mobile clients.
 */

// ------------------------------------------------------------------
// Standard API Response Wrapper
// ------------------------------------------------------------------

/**
 * Standard API response wrapper for all endpoints.
 * All successful responses must return this structure.
 * @template T - The type of the data payload
 */
export interface ApiResponse<T = unknown> {
  /** Indicates if the request was successful */
  success: boolean;
  /** The actual data payload (present if success is true) */
  data?: T;
  /** Error details (present if success is false) */
  error?: ApiError;
  /** Optional metadata (pagination, etc.) */
  meta?: ApiMeta;
}

/**
 * Metadata for API responses, typically used for pagination
 */
export interface ApiMeta {
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  [key: string]: unknown;
}

// ------------------------------------------------------------------
// Error Types
// ------------------------------------------------------------------

/**
 * Standardized error object structure
 */
export interface ApiError {
  /** Machine-readable error code */
  code: ErrorCode;
  /** Human-readable error message */
  message: string;
  /** Optional additional details about the error */
  details?: unknown;
}

/**
 * Canonical error codes shared between backend and mobile.
 * These codes drive error handling logic and UI feedback.
 */
export enum ErrorCode {
  // Client Errors (4xx)
  VALIDATION_ERROR = "VALIDATION_ERROR",
  UNAUTHORIZED = "UNAUTHORIZED",
  FORBIDDEN = "FORBIDDEN",
  NOT_FOUND = "NOT_FOUND",
  CONFLICT = "CONFLICT",
  FILE_TOO_LARGE = "FILE_TOO_LARGE",
  INVALID_FILE_TYPE = "INVALID_FILE_TYPE",
  RATE_LIMITED = "RATE_LIMITED",
  // Server Errors (5xx)
  INTERNAL_ERROR = "INTERNAL_ERROR",
  SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE",
  // AI/RAG Specific Errors
  EMBEDDING_FAILED = "EMBEDDING_FAILED",
  LLM_UNAVAILABLE = "LLM_UNAVAILABLE",
  NO_RELEVANT_CONTENT = "NO_RELEVANT_CONTENT",
  PROCESSING_FAILED = "PROCESSING_FAILED",
  // External Service Errors
  FIREBASE_ERROR = "FIREBASE_ERROR",
  PINECONE_ERROR = "PINECONE_ERROR",
  GEMINI_ERROR = "GEMINI_ERROR",
}

// ------------------------------------------------------------------
// HTTP Status Constants
// ------------------------------------------------------------------

export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  PAYLOAD_TOO_LARGE: 413,
  UNSUPPORTED_MEDIA_TYPE: 415,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

export type HttpStatus = (typeof HTTP_STATUS)[keyof typeof HTTP_STATUS];
