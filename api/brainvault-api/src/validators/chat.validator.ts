import { z } from "zod";
import { uuidSchema } from "./common.validator";

/**
 * Reusable schema for message content.
 * Enforces strict length limits to prevent token abuse.
 */
export const messageContentSchema = z
  .string()
  .trim()
  .min(1, "Message cannot be empty")
  .max(1000, "Message cannot exceed 1000 characters");

/**
 * Validates the chat request body.
 * Used for the main RAG endpoint: POST /v1/documents/:id/chat
 */
export const chatRequestSchema = z.object({
  body: z.object({
    message: messageContentSchema,
    sessionId: uuidSchema.optional(),
  }),
});

/**
 * Validates session ID parameters.
 * Used for session-specific routes.
 */
export const sessionIdSchema = z.object({
  params: z.object({
    sessionId: uuidSchema,
  }),
});
