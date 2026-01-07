/**
 * Global Error Handling Middleware
 * Catches all errors and formats them using standard API response structure
 */

import { Request, Response, NextFunction } from "express";
import { ApiResponse, ERROR_CODES } from "../types";

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: keyof typeof ERROR_CODES,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

/**
 * Global error handler middleware
 * Catches all errors and returns standard error response
 */
export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const timestamp = new Date().toISOString();

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
  console.error(`[${timestamp}] Error (${code}):`, {
    statusCode,
    code,
    message,
    path: req.path,
    method: req.method,
    details,
  });

  // Return standard error response
  const response: ApiResponse<null> = {
    success: false,
    error: {
      code,
      message,
      ...(details && { details }),
    },
    meta: {
      timestamp,
    },
  };

  res.status(statusCode).json(response);
}

/**
 * 404 Not Found handler
 */
export function notFoundHandler(req: Request, res: Response): void {
  const timestamp = new Date().toISOString();
  const response: ApiResponse<null> = {
    success: false,
    error: {
      code: ERROR_CODES.NOT_FOUND,
      message: `Route not found: ${req.method} ${req.path}`,
    },
    meta: {
      timestamp,
    },
  };

  res.status(404).json(response);
}
