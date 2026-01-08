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
  // Option 1: Complete JSON service account (NEW - preferred)
  firebaseCredentials?: string;
  firebaseServiceAccountKey?: string;

  // Option 2: Individual fields (deprecated but supported for backwards compatibility)
  firebaseProjectId?: string;
  firebasePrivateKey?: string;
  firebaseClientEmail?: string;

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
 * Supports two Firebase configuration approaches:
 * 1. Full JSON credentials in FIREBASE_CREDENTIALS (preferred)
 * 2. Individual variables: FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL
 */
function loadEnvironment(): EnvironmentConfig {
  const nodeEnv =
    (process.env.NODE_ENV as "development" | "production" | "test") ||
    "development";
  const port = parseInt(process.env.PORT || "3000", 10);
  const googleApiKey = process.env.GOOGLE_API_KEY;

  // Firebase configuration - support both JSON and individual variables
  const firebaseCredentials = process.env.FIREBASE_CREDENTIALS;
  const firebaseServiceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
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

  // Validate Firebase configuration
  // Accept either: FIREBASE_CREDENTIALS (JSON) or individual fields
  const hasJsonCredentials = firebaseCredentials || firebaseServiceAccountKey;
  const hasIndividualFields =
    firebaseProjectId && firebasePrivateKey && firebaseClientEmail;

  if (!hasJsonCredentials && !hasIndividualFields) {
    throw new Error(
      "Missing Firebase configuration. Provide either:\n" +
        "1. FIREBASE_CREDENTIALS (JSON service account key), or\n" +
        "2. FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL"
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
    // Firebase - provide both JSON and individual fields if available
    firebaseCredentials: firebaseCredentials || firebaseServiceAccountKey,
    firebaseProjectId: firebaseProjectId,
    firebasePrivateKey: firebasePrivateKey,
    firebaseClientEmail: firebaseClientEmail,
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
