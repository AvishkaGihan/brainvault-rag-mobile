/**
 * Route Aggregator
 * Centralizes all route definitions
 *
 * Middleware Application Order (Story 2.7):
 * 1. Health check (bypasses auth & rate limiting)
 * 2. Authentication (verifyAuth) - populates req.user with Firebase UID
 * 3. General rate limiting (100 requests per 15 minutes per user)
 * 4. Route-specific middleware (e.g., chatApiLimiter for chat routes)
 * 5. Route handlers (controllers)
 *
 * This order is critical:
 * - Health check must be first (no auth required)
 * - Auth must come before rate limiting (so we can key by UID)
 * - Rate limiters use req.user.uid set by auth middleware
 */

import { Router } from "express";
import { router as healthRoutes } from "./health.routes";
import { documentRoutes } from "./document.routes";
import { chatRoutes } from "./chat.routes";
import { verifyAuth } from "../middleware/auth.middleware";
import {
  generalApiLimiter,
  chatApiLimiter,
} from "../middleware/rateLimiter.middleware";

const router = Router();

/**
 * Health check routes (no auth, no rate limit)
 * AC4: Health check exemption
 */
router.use("/health", healthRoutes);

/**
 * Apply authentication middleware to all routes below
 * AC1, AC2, AC3: Verify Firebase JWT tokens
 * Sets req.user = { uid, email } for authenticated requests
 */
router.use(verifyAuth);

/**
 * Apply general rate limiter after auth (keys by req.user.uid)
 * AC5: 100 requests per 15 minutes per user
 */
router.use(generalApiLimiter);

/**
 * Document routes (Story 3.3)
 * POST /api/v1/documents/upload - Upload PDF document
 * POST /api/v1/documents/text - Create text document
 */
router.use("/v1/documents", documentRoutes);

/**
 * Chat routes (Story 5.4)
 * POST /api/v1/documents/:documentId/chat
 */
router.use("/v1/documents/:documentId/chat", chatApiLimiter, chatRoutes);

/**
 * Future routes will be added here:
 * - User routes: /api/v1/users
 * - Chat routes: /api/v1/documents/:id/chat (with chatApiLimiter)
 *
 * Example for chat routes (future story):
 * router.use("/v1/documents/:id/chat", chatApiLimiter, chatRoutes);
 */

export { router };
