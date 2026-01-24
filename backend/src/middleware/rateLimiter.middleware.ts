/**
 * Rate Limiting Middleware
 * Protects API from abuse and manages free-tier quotas
 *
 * Story: 2.7 - Backend Auth Middleware
 *
 * Strategy:
 * - General API: 100 requests per 15 minutes per user
 * - Chat/Query: 10 requests per 1 minute per user (stricter, LLM expensive)
 * - Key: Firebase UID (req.user.uid) or IP fallback
 *
 * Rationale:
 * - Protects Gemini API free tier (60 req/min project-wide)
 * - Prevents single user exhausting Pinecone free tier
 * - Stricter chat limit prevents rapid-fire queries
 *
 * AC5, AC6
 */

import rateLimit from "express-rate-limit";
import { ApiResponse } from "../types";
import { createErrorResponse } from "../utils/helpers";

/**
 * General API rate limiter
 * Limits: 100 requests per 15 minutes per user
 * Key: Firebase UID (req.user.uid) or IP address fallback
 * Protects: All API endpoints except health check
 *
 * Prevents abuse of:
 * - Document upload endpoints
 * - Document list/metadata endpoints
 * - General API operations
 */
export const generalApiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window per user
  keyGenerator: (req) => {
    // Always prefer Firebase UID (set by auth middleware)
    // IP fallback never occurs on protected routes (auth middleware runs first)
    return req.user?.uid || "unauthenticated";
  },
  skipFailedRequests: false, // Count all requests
  validate: false, // Disable validation - we don't rely on IP tracking
  handler: (req, res) => {
    const response = createErrorResponse(
      "RATE_LIMIT_EXCEEDED",
      "Too many requests. Please try again in 15 minutes.",
    );
    res.status(429).json(response);
  },
  standardHeaders: true, // Return rate limit info in `RateLimit-*` headers
  legacyHeaders: false, // Disable `X-RateLimit-*` headers
  skipSuccessfulRequests: false, // Count all requests, even successful ones
});

/**
 * Chat/Query rate limiter (stricter)
 * Limits: 10 requests per 1 minute per user
 * Key: Firebase UID (req.user.uid) or IP address fallback
 * Protects: Chat/query endpoints (/api/v1/documents/:id/chat, etc.)
 *
 * Rationale:
 * - LLM inference is expensive (Gemini API quotas)
 * - Embedding generation consumes resources
 * - Vector search queries cost per operation
 * - Prevents rapid-fire queries that waste tokens
 *
 * Stricter than general API to protect free-tier quotas
 */
export const chatApiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 requests per window per user
  keyGenerator: (req) => {
    // Always prefer Firebase UID (set by auth middleware)
    // IP fallback never occurs on protected routes (auth middleware runs first)
    return req.user?.uid || "unauthenticated";
  },
  skipFailedRequests: false,
  validate: false, // Disable validation - we don't rely on IP tracking
  handler: (req, res) => {
    const response = createErrorResponse(
      "RATE_LIMIT_EXCEEDED",
      "Query limit reached. Please wait a moment.",
    );
    res.status(429).json(response);
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,
});
