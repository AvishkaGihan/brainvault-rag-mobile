/**
 * Helper utility functions
 * Common utilities used across the application
 */

import { ApiResponse, ERROR_CODES } from "../types";

/**
 * Sleep utility - resolve after n milliseconds
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Get current timestamp in ISO format
 */
export function getCurrentTimestamp(): string {
  return new Date().toISOString();
}

/**
 * Create standardized error response
 */
export function createErrorResponse(
  code: keyof typeof ERROR_CODES,
  message: string,
  details?: Record<string, unknown>,
): ApiResponse<null> {
  return {
    success: false,
    error: { code, message, ...(details && { details }) },
    meta: { timestamp: getCurrentTimestamp() },
  };
}

/**
 * Retry utility - retry async operations with exponential backoff
 */
export interface RetryOptions {
  maxAttempts?: number;
  delayMs?: number;
  backoffMultiplier?: number;
}

export async function retry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {},
): Promise<T> {
  const { maxAttempts = 3, delayMs = 100, backoffMultiplier = 2 } = options;

  let lastError: Error | undefined;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt < maxAttempts - 1) {
        const delay = delayMs * Math.pow(backoffMultiplier, attempt);
        await sleep(delay);
      }
    }
  }

  throw lastError || new Error("Max retry attempts reached");
}
