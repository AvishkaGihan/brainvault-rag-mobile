import dotenv from "dotenv";

dotenv.config();

/**
 * Environment variable loader and validator
 * Centralizes all environment configuration with type safety
 */

interface EnvironmentConfig {
  // Server
  nodeEnv: "development" | "production" | "test";
  port: number;

  // Firebase (required for production)
  firebaseProjectId: string;
  firebasePrivateKey: string;
  firebaseClientEmail: string;

  // Pinecone (required for production)
  pineconeApiKey: string;
  pineconeIndex: string;

  // LLM (required for all environments)
  llmProvider: string;
  googleApiKey: string;

  // Optional providers
  openaiApiKey?: string;
  anthropicApiKey?: string;
}

/**
 * Load and validate environment variables
 * Throws error if critical variables are missing in ANY environment
 */
function loadEnvironment(): EnvironmentConfig {
  const nodeEnv =
    (process.env.NODE_ENV as "development" | "production" | "test") ||
    "development";
  const port = parseInt(process.env.PORT || "3000", 10);
  const googleApiKey = process.env.GOOGLE_API_KEY;
  const firebaseProjectId = process.env.FIREBASE_PROJECT_ID;
  const firebasePrivateKey = process.env.FIREBASE_PRIVATE_KEY;
  const firebaseClientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const pineconeApiKey = process.env.PINECONE_API_KEY;
  const pineconeIndex = process.env.PINECONE_INDEX;

  // Validate port is valid number
  if (isNaN(port) || port < 0 || port > 65535) {
    throw new Error(`Invalid PORT: ${process.env.PORT}. Must be 0-65535`);
  }

  // Validate LLM configuration (required in all environments)
  if (!googleApiKey) {
    throw new Error(
      "Missing required environment variable: GOOGLE_API_KEY (required for LLM functionality)"
    );
  }

  // Validate Firebase configuration (required for all environments)
  const firebaseErrors: string[] = [];
  if (!firebaseProjectId) firebaseErrors.push("FIREBASE_PROJECT_ID");
  if (!firebasePrivateKey) firebaseErrors.push("FIREBASE_PRIVATE_KEY");
  if (!firebaseClientEmail) firebaseErrors.push("FIREBASE_CLIENT_EMAIL");

  if (firebaseErrors.length > 0) {
    throw new Error(
      `Missing required Firebase environment variables: ${firebaseErrors.join(
        ", "
      )}`
    );
  }

  // Validate Pinecone configuration (required for all environments)
  const pineconeErrors: string[] = [];
  if (!pineconeApiKey) pineconeErrors.push("PINECONE_API_KEY");
  if (!pineconeIndex) pineconeErrors.push("PINECONE_INDEX");

  if (pineconeErrors.length > 0) {
    throw new Error(
      `Missing required Pinecone environment variables: ${pineconeErrors.join(
        ", "
      )}`
    );
  }

  const config: EnvironmentConfig = {
    nodeEnv,
    port,
    firebaseProjectId: firebaseProjectId as string,
    firebasePrivateKey: firebasePrivateKey as string,
    firebaseClientEmail: firebaseClientEmail as string,
    pineconeApiKey: pineconeApiKey as string,
    pineconeIndex: pineconeIndex as string,
    llmProvider: process.env.LLM_PROVIDER || "gemini",
    googleApiKey: googleApiKey as string,
    openaiApiKey: process.env.OPENAI_API_KEY,
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
  };

  return config;
}

export const env = loadEnvironment();
export type { EnvironmentConfig };
