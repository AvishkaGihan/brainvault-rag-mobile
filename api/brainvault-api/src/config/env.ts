import dotenv from "dotenv";
import { z } from "zod";

// Load environment variables from .env file
dotenv.config();

/**
 * Zod schema for environment variable validation.
 * Ensures strict typing and existence of required variables.
 */
const envSchema = z.object({
  // System
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),
  PORT: z.string().default("3000"),

  // Firebase
  FIREBASE_PROJECT_ID: z.string().min(1, "FIREBASE_PROJECT_ID is required"),
  FIREBASE_CLIENT_EMAIL: z.string().min(1, "FIREBASE_CLIENT_EMAIL is required"),
  FIREBASE_PRIVATE_KEY: z.string().min(1, "FIREBASE_PRIVATE_KEY is required"),

  // Pinecone
  PINECONE_API_KEY: z.string().min(1, "PINECONE_API_KEY is required"),
  PINECONE_INDEX_NAME: z.string().default("brainvault-index"),

  // LLM / AI
  GEMINI_API_KEY: z.string().min(1, "GEMINI_API_KEY is required"),
  LLM_PROVIDER: z.enum(["gemini", "replicate"]).default("gemini"),

  // Application Limits
  RATE_LIMIT_MAX: z.string().default("100"),
});

// Validate process.env
const parsedEnv = envSchema.safeParse(process.env);

if (!parsedEnv.success) {
  console.error(
    "❌ Invalid environment variables:",
    JSON.stringify(parsedEnv.error.format(), null, 2)
  );
  process.exit(1);
}

const { data } = parsedEnv;

/**
 * Validated and sanitized environment configuration.
 * Must be used instead of process.env throughout the application.
 */
export const env = {
  ...data,
  // Normalize private key newlines (fixes issues with .env file escaping)
  FIREBASE_PRIVATE_KEY: data.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
};
