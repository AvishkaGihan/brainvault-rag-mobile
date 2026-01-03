import { z } from "zod";
import { uuidSchema } from "./common.validator";

// Validation constants matching strict constraints
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB in bytes
const ACCEPTED_MIME_TYPES = ["application/pdf"];

/**
 * Validates document upload requests.
 * Expects the validation middleware to include `file` in the validation context.
 */
export const uploadDocumentSchema = z.object({
  file: z.object({
    mimetype: z.string().refine((val) => ACCEPTED_MIME_TYPES.includes(val), {
      message: "Only PDF files are allowed (application/pdf)",
    }),
    size: z.number().max(MAX_FILE_SIZE, {
      message: "File size must be less than 5MB",
    }),
    originalname: z.string().min(1, "File name is required"),
  }),
});

/**
 * Validates route parameters containing a document ID.
 */
export const documentIdSchema = z.object({
  params: z.object({
    id: uuidSchema,
  }),
});

/**
 * Validates document metadata update requests.
 */
export const updateDocumentSchema = z.object({
  params: z.object({
    id: uuidSchema,
  }),
  body: z.object({
    name: z.string().min(1, "Name cannot be empty").max(255).optional(),
  }),
});
