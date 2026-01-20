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
