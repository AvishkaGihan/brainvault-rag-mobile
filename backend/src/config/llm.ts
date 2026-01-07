/**
 * Large Language Model Configuration
 * Factory for creating LLM instances with consistent configuration
 * Currently configured for Google Gemini Pro
 */

import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import dotenv from "dotenv";
dotenv.config();

/**
 * Create a configured LLM instance
 * Returns a ChatGoogleGenerativeAI instance with standard settings for RAG operations
 *
 * @returns Configured LLM instance ready for chat completions
 */
export const createLLM = () => {
  return new ChatGoogleGenerativeAI({
    model: "gemini-pro",
    apiKey: process.env.GOOGLE_API_KEY,
    temperature: 0.3,
  });
};
