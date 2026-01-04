/**
 * Custom application error class to standardize error handling across the API.
 * extends native Error to include HTTP status codes and operational error codes.
 */
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: object;

  constructor(
    statusCode: number,
    code: string,
    message: string,
    details?: object
  ) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.name = this.constructor.name;

    // Capture stack trace excluding constructor call
    Error.captureStackTrace(this, this.constructor);
  }

  // --- Factory Methods for Common Errors ---

  /**
   * 400 Bad Request
   */
  static badRequest(message = "Bad Request", details?: object): AppError {
    return new AppError(400, "BAD_REQUEST", message, details);
  }

  /**
   * 401 Unauthorized
   */
  static unauthorized(message = "Unauthorized access"): AppError {
    return new AppError(401, "UNAUTHORIZED", message);
  }

  /**
   * 403 Forbidden
   */
  static forbidden(message = "Access forbidden"): AppError {
    return new AppError(403, "FORBIDDEN", message);
  }

  /**
   * 404 Not Found
   */
  static notFound(resource = "Resource"): AppError {
    return new AppError(404, "NOT_FOUND", `${resource} not found`);
  }

  /**
   * 413 Payload Too Large (File Uploads)
   */
  static fileTooLarge(message = "File is too large"): AppError {
    return new AppError(413, "FILE_TOO_LARGE", message);
  }

  /**
   * 415 Unsupported Media Type
   */
  static invalidFileType(message = "Invalid file type"): AppError {
    return new AppError(415, "INVALID_FILE_TYPE", message);
  }

  /**
   * 429 Too Many Requests
   */
  static rateLimited(message = "Too many requests"): AppError {
    return new AppError(429, "RATE_LIMITED", message);
  }

  /**
   * 500 Internal Server Error
   */
  static internal(message = "Internal server error"): AppError {
    return new AppError(500, "INTERNAL_ERROR", message);
  }

  /**
   * 503 Service Unavailable
   */
  static serviceUnavailable(service: string): AppError {
    return new AppError(
      503,
      "SERVICE_UNAVAILABLE",
      `${service} service is currently unavailable`
    );
  }

  /**
   * 503 LLM Service Specific Error
   */
  static llmUnavailable(details?: object): AppError {
    return new AppError(
      503,
      "LLM_UNAVAILABLE",
      "AI service is currently unavailable",
      details
    );
  }

  /**
   * 500 Embedding Service Specific Error
   */
  static embeddingFailed(details?: object): AppError {
    return new AppError(
      500,
      "EMBEDDING_FAILED",
      "Failed to generate content embeddings",
      details
    );
  }
}
