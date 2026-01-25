/**
 * Large Language Model Configuration
 * Factory for creating LLM instances with consistent configuration
 * Currently configured for Google Gemini Pro
 */

import {
  ChatGoogleGenerativeAI,
  GoogleGenerativeAIEmbeddings,
} from "@langchain/google-genai";
import { env } from "./env";
import { AppError, ERROR_CODES } from "../types/api.types";

/**
 * Create a configured LLM instance
 * Returns a ChatGoogleGenerativeAI instance with standard settings for RAG operations
 *
 * @returns Configured LLM instance ready for chat completions
 */
export const createLLM = () => {
  return new ChatGoogleGenerativeAI({
    model: "gemini-pro",
    apiKey: env.googleApiKey,
    temperature: 0.3,
  });
};

/**
 * Create a configured embedding model instance
 * Defaults to Gemini text-embedding-004
 */
export const createEmbeddingModel = () => {
  const provider = env.llmProvider || "gemini";

  if (provider !== "gemini") {
    throw new AppError(
      ERROR_CODES.CONFIGURATION_ERROR,
      `Unsupported LLM provider for embeddings: ${provider}`,
      500,
    );
  }

  return new GoogleGenerativeAIEmbeddings({
    apiKey: env.googleApiKey,
    model: "text-embedding-004",
  });
};
