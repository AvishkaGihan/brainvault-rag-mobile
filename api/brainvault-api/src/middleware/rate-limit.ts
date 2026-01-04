import rateLimit from "express-rate-limit";
import { Request, Response } from "express";
import { env } from "../config/env";
import { AuthenticatedRequest } from "../types/user.types";

/**
 * Rate limit middleware to protect API quotas.
 * Limits requests to 100 (configurable) per 15 minutes per user.
 * * Strategy:
 * - Window: 15 minutes
 * - Max: RATE_LIMIT_MAX (default 100)
 * - Key: req.user.uid (User ID)
 * - Store: MemoryStore (default) - sufficient for single instance MVP
 */
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: parseInt(env.RATE_LIMIT_MAX) || 100, // Limit each user to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers

  // Use Firebase UID as the key for rate limiting
  keyGenerator: (req: Request): string => {
    // We assume this middleware is placed AFTER auth middleware
    const authReq = req as AuthenticatedRequest;
    return authReq.user?.uid || req.ip || "anonymous";
  },

  // Custom response format to match ApiError structure
  handler: (req: Request, res: Response) => {
    const retryAfter = Math.ceil(
      (res.getHeader("Retry-After") as number) || 900
    );

    res.status(429).json({
      success: false,
      error: {
        code: "RATE_LIMITED",
        message: "Too many requests. Please try again later.",
        details: {
          retryAfter: retryAfter,
        },
      },
    });
  },
});
