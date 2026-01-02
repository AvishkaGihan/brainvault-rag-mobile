/**
 * Configuration options for the retry mechanism.
 */
export interface RetryOptions {
  /** Maximum number of retry attempts. Default: 3 */
  maxRetries?: number;
  /** Initial delay in milliseconds before the first retry. Default: 1000 */
  baseDelay?: number;
  /** Maximum delay in milliseconds between retries. Default: 10000 */
  maxDelay?: number;
  /**
   * Optional condition to determine if an error should trigger a retry.
   * If provided and returns false, the error is thrown immediately.
   */
  shouldRetry?: (error: any) => boolean;
}

/**
 * Pauses execution for a specified duration.
 * @param ms - Duration to sleep in milliseconds
 */
export const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Executes an async operation with exponential backoff retry logic.
 * Useful for handling transient failures in external services (LLM, Database, etc.).
 * Backoff formula: min(baseDelay * 2^attempt, maxDelay)
 * @param operation - The async function to execute
 * @param options - Configuration options for retries
 * @returns The result of the operation
 * @throws The last error encountered if all retries fail
 */
export async function retryWithBackoff<T>(
  operation: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 10000,
    shouldRetry = () => true,
  } = options;

  let lastError: any;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;

      // Check if we should stop retrying
      if (attempt === maxRetries || !shouldRetry(error)) {
        throw error;
      }

      // Calculate exponential backoff
      const delay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);

      // Optional: Add some jitter to prevent thundering herd
      const jitter = Math.random() * 100;

      console.warn(
        `Operation failed (attempt ${attempt + 1}/${maxRetries}). Retrying in ${delay + jitter}ms...`,
        error instanceof Error ? error.message : String(error)
      );

      await sleep(delay + jitter);
    }
  }

  throw lastError;
}

/**
 * Wraps a promise with a timeout.
 * If the operation takes longer than the specified duration, it rejects with a timeout error.
 * @param operation - The promise to wrap
 * @param durationMs - Timeout duration in milliseconds
 * @param errorMessage - Optional custom error message
 * @returns The result of the operation
 */
export async function withTimeout<T>(
  operation: Promise<T>,
  durationMs: number,
  errorMessage = "Operation timed out"
): Promise<T> {
  let timeoutHandle: NodeJS.Timeout;

  const timeoutPromise = new Promise<never>((_, reject) => {
    timeoutHandle = setTimeout(() => {
      reject(new Error(`${errorMessage} after ${durationMs}ms`));
    }, durationMs);
  });

  try {
    return await Promise.race([operation, timeoutPromise]);
  } finally {
    clearTimeout(timeoutHandle!);
  }
}
