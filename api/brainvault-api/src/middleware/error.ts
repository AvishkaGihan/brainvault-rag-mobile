import { Request, Response, NextFunction } from "express";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";

/**
 * Global error handling middleware.
 * Catches all errors, logs them, and returns a consistent JSON response.
 * Must be the last middleware registered in the application.
 */
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = err;

  // 1. Determine if it's a known AppError or an unhandled exception
  let statusCode = 500;
  let errorCode = "INTERNAL_ERROR";
  let message = "An unexpected error occurred";
  let details: object | undefined;

  if (error instanceof AppError) {
    statusCode = error.statusCode;
    errorCode = error.code;
    message = error.message;
    details = error.details;
  } else {
    // Hide internal details for unknown errors in production
    // But allow the original error message if it's not sensitive?
    // Generally safe to keep generic for 500s to avoid leaking info.
    if (process.env.NODE_ENV !== "production") {
      message = error.message;
    }
  }

  // 2. Log the error
  // We log all 500s as errors, and 4xx as warnings or info depending on severity
  const logContext = {
    code: errorCode,
    path: req.path,
    method: req.method,
    ip: req.ip,
    userId: (req as any).user?.uid, // specific to our AuthenticatedRequest
    details,
    stack: error.stack,
  };

  if (statusCode >= 500) {
    logger.error(`[${errorCode}] ${message}`, logContext);
  } else {
    logger.warn(`[${errorCode}] ${message}`, logContext);
  }

  // 3. Send response
  res.status(statusCode).json({
    success: false,
    error: {
      code: errorCode,
      message: message,
      details: details,
    },
  });
};
