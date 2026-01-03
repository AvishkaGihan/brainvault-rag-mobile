import { z } from "zod";

/**
 * Reusable schema for UUID validation.
 * Ensures IDs strictly follow UUID v4 format.
 */
export const uuidSchema = z.uuid("Invalid ID format");

/**
 * Reusable schema for pagination parameters.
 * Provides sensible defaults for list endpoints.
 */
export const paginationSchema = z.object({
  query: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
  }),
});

/**
 * Reusable schema for email validation.
 */
export const emailSchema = z
  .email("Invalid email address")
  .toLowerCase()
  .trim();

/**
 * Reusable schema for ISO 8601 timestamps.
 */
export const timestampSchema = z.iso.datetime({
  message: "Invalid ISO 8601 date string",
});
