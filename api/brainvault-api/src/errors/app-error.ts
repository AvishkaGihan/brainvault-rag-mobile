/**
 * Custom application error class for standardized error handling.
 * Extends the native Error class to provide HTTP status codes and error codes
 * for proper API error responses and middleware handling.
 */
export class AppError extends Error {
  /**
   * HTTP status code for the error (e.g., 400, 404, 500)
   */
  public readonly statusCode: number;

  /**
   * Machine-readable error code for API responses
   */
  public readonly code: string;

  /**
   * Additional error details or context
   */
  public readonly details?: unknown;

  /**
   * Creates a new AppError instance.
   * @param statusCode HTTP status code
   * @param message Human-readable error message
   * @param code Optional machine-readable error code (defaults to status code)
   * @param details Optional additional error details
   */
  constructor(
    statusCode: number,
    message: string,
    code?: string,
    details?: unknown
  ) {
    super(message);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.code = code || `ERROR_${statusCode}`;
    this.details = details;

    // Ensure proper prototype chain for instanceof checks
    Object.setPrototypeOf(this, AppError.prototype);
  }

  /**
   * Converts the error to a JSON-serializable object for API responses.
   */
  toJSON() {
    return {
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      details: this.details,
    };
  }
}
