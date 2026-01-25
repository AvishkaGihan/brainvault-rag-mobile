/**
 * Global Error Handling Middleware
 * Catches all errors and formats them using standard API response structure
 */

import { Request, Response, NextFunction } from "express";
import { ApiResponse, ERROR_CODES, AppError } from "../types";
import { createErrorResponse } from "../utils/helpers";
import { logger } from "../utils/logger";

/**
 * Global error handler middleware
 * Catches all errors and returns standard error response
 */
export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  // Default error
  let statusCode = 500;
  let code: keyof typeof ERROR_CODES = "INTERNAL_SERVER_ERROR";
  let message = "An unexpected error occurred";
  let details: Record<string, unknown> | undefined;

  // Handle AppError instances
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    code = err.code;
    message = err.message;
    details = err.details;
  } else if (err instanceof Error) {
    message = err.message;
  } else if (typeof err === "string") {
    message = err;
  }

  // Log error with context
  logger.error("Request error", {
    statusCode,
    code,
    message,
    path: req.path,
    method: req.method,
    details,
  });

  // Return standard error response
  const response = createErrorResponse(code, message, details);
  res.status(statusCode).json(response);
}

/**
 * 404 Not Found handler
 */
export function notFoundHandler(req: Request, res: Response): void {
  const response = createErrorResponse(
    ERROR_CODES.NOT_FOUND,
    `Route not found: ${req.method} ${req.path}`,
  );
  res.status(404).json(response);
}
