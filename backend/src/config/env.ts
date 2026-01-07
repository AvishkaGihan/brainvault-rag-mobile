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

  // Firebase
  firebaseProjectId?: string;
  firebasePrivateKey?: string;
  firebaseClientEmail?: string;

  // Pinecone
  pineconeApiKey?: string;
  pineconeIndex?: string;

  // LLM
  llmProvider?: string;
  googleApiKey?: string;
  openaiApiKey?: string;
  anthropicApiKey?: string;
}

/**
 * Load and validate environment variables
 * Throws error if critical variables are missing in production
 */
function loadEnvironment(): EnvironmentConfig {
  const config: EnvironmentConfig = {
    nodeEnv:
      (process.env.NODE_ENV as "development" | "production" | "test") ||
      "development",
    port: parseInt(process.env.PORT || "3000", 10),
    firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
    firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY,
    firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    pineconeApiKey: process.env.PINECONE_API_KEY,
    pineconeIndex: process.env.PINECONE_INDEX,
    llmProvider: process.env.LLM_PROVIDER || "gemini",
    googleApiKey: process.env.GOOGLE_API_KEY,
    openaiApiKey: process.env.OPENAI_API_KEY,
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
  };

  // Validate critical variables in production
  if (config.nodeEnv === "production") {
    const requiredVars = [
      "firebaseProjectId",
      "firebasePrivateKey",
      "firebaseClientEmail",
      "pineconeApiKey",
      "pineconeIndex",
    ];

    const missing = requiredVars.filter(
      (key) => !config[key as keyof EnvironmentConfig]
    );
    if (missing.length > 0) {
      throw new Error(
        `Missing required environment variables: ${missing.join(", ")}`
      );
    }
  }

  return config;
}

export const env = loadEnvironment();
export type { EnvironmentConfig };
