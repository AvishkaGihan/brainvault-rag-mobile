/**
 * Authentication Middleware
 * Verifies Firebase JWT tokens on all protected routes
 *
 * Story: 2.7 - Backend Auth Middleware
 *
 * Flow:
 * 1. Extract Authorization header from request
 * 2. Verify token format: "Bearer <token>"
 * 3. Verify token with Firebase Admin SDK
 * 4. Populate req.user with Firebase UID and email
 * 5. Proceed to next middleware or return 401
 *
 * AC1, AC2, AC3, AC4, AC7
 */

import { Request, Response, NextFunction } from "express";
import { auth } from "../config/firebase";
import { AppError } from "../types";

/**
 * Verify Firebase JWT token and populate req.user
 *
 * Sets req.user with:
 * - uid: Firebase user ID (string)
 * - email: User email (string | undefined)
 *
 * Throws AppError 401 if:
 * - Authorization header missing or malformed
 * - Token verification fails (invalid, expired, revoked)
 *
 * @throws {AppError} 401 UNAUTHORIZED
 */
export async function verifyAuth(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    // Extract Authorization header
    const authHeader = req.headers.authorization;

    // Check if header exists and has Bearer format
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new AppError(
        "UNAUTHORIZED",
        "No authentication token provided",
        401,
      );
    }

    // Extract token from "Bearer <token>"
    const token = authHeader.slice(7);

    if (!token || !token.trim()) {
      throw new AppError(
        "UNAUTHORIZED",
        "No authentication token provided",
        401,
      );
    }

    // Verify token with Firebase Admin SDK
    try {
      const decodedToken = await auth.verifyIdToken(token);

      // Populate req.user with Firebase UID and email
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
      };

      // Proceed to next middleware
      next();
    } catch (verifyError) {
      // Token verification failed (invalid, expired, revoked)
      throw new AppError(
        "UNAUTHORIZED",
        "Invalid or expired authentication token",
        401,
      );
    }
  } catch (error) {
    // Pass error to global error handler
    next(error);
  }
}
