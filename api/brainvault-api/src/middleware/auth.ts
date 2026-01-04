import { Response, NextFunction } from "express";
import { auth } from "../config/firebase";
import { AppError } from "../errors/app-error";
import { AuthenticatedRequest } from "../types/user.types";

/**
 * Middleware to verify Firebase ID tokens and attach user context to the request.
 * * Verifies the 'Authorization' header containing the Bearer token.
 * Decodes the token using Firebase Admin SDK.
 * Attaches uid, email, and isAnonymous status to req.user.
 */
export const authenticateToken = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      // 401 Unauthorized - Missing or invalid header format
      throw AppError.unauthorized("Missing or invalid authorization header");
    }

    const token = authHeader.split("Bearer ")[1];

    if (!token) {
      throw AppError.unauthorized("Token not found in authorization header");
    }

    try {
      const decodedToken = await auth.verifyIdToken(token);

      // Attach user context to the request object
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        isAnonymous:
          decodedToken.provider_id === "anonymous" ||
          decodedToken.firebase?.sign_in_provider === "anonymous",
      };

      next();
    } catch (error) {
      // Firebase verification failed (expired, invalid signature, etc.)
      throw new AppError(401, "INVALID_TOKEN", "Token is invalid or expired", {
        originalError: error,
      });
    }
  } catch (error) {
    next(error);
  }
};
