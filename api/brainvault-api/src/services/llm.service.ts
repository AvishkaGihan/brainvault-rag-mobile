import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { HumanMessage } from "@langchain/core/messages";
import { env } from "../config/env";
import { logger } from "../config/logger";
import { retryWithBackoff } from "../utils/async";
import { embeddingService } from "./embedding.service";
import { AppError } from "../errors/app-error";

/**
 * Configuration options for LLM generation
 */
export interface LLMOptions {
  temperature?: number;
  maxTokens?: number;
}

/**
 * Interface defining the contract for any LLM provider (Gemini, Llama, etc.)
 */
export interface LLMProvider {
  /**
   * Generates a text response based on the provided prompt.
   * The prompt is expected to contain the full context and question.
   */
  generateResponse(prompt: string, options?: LLMOptions): Promise<string>;

  /**
   * Generates a vector embedding for the given text.
   * Delegates to the centralized EmbeddingService for consistency.
   */
  generateEmbedding(text: string): Promise<number[]>;
}

/**
 * Strict system prompt to prevent hallucinations and enforce citation format.
 * Used by RAG Service to construct the final prompt.
 */
export const RAG_SYSTEM_PROMPT_TEMPLATE = `You are BrainVault, an AI assistant that answers questions ONLY based on the provided document context.

STRICT RULES:

1. ONLY use information from the provided context
2. If context doesn't contain relevant information, say "I couldn't find relevant information in the provided documents."
3. NEVER make up or infer information not in context
4. Always cite sources using [Page X] format inline with the text (e.g. "The sky is blue [Page 2].")
5. Keep answers concise but complete

CONTEXT:
{context}

QUESTION:
{question}`;

/**
 * Implementation of LLMProvider using Google's Gemini models.
 */
class GeminiProvider implements LLMProvider {
  private model: ChatGoogleGenerativeAI;
  private readonly defaultOptions: LLMOptions = {
    temperature: 0.1, // Low temperature for factual RAG responses
    maxTokens: 1024,
  };

  constructor() {
    this.model = new ChatGoogleGenerativeAI({
      apiKey: env.GEMINI_API_KEY,
      model: "gemini-1.5-flash",
      temperature: this.defaultOptions.temperature,
      maxOutputTokens: this.defaultOptions.maxTokens,
    });
  }

  async generateResponse(
    prompt: string,
    options?: LLMOptions
  ): Promise<string> {
    try {
      // Merge defaults with runtime options
      const effectiveOptions = { ...this.defaultOptions, ...options };

      // Update model params if they differ from defaults (LangChain model instances are mutable or we'd recreate)
      // For simplicity/performance in this singleton pattern, we bind options here or pass to invoke if supported.
      // LangChain's bind methods are preferred, or simply using the configured instance if options rarely change per request.
      // Given the blueprint requirements, we'll assume the instance config handles most cases,
      // but strictly we should apply the temperature overrides if passed.

      const modelWithConfig = options
        ? new ChatGoogleGenerativeAI({
            apiKey: env.GEMINI_API_KEY,
            model: "gemini-1.5-flash",
            temperature: effectiveOptions.temperature,
            maxOutputTokens: effectiveOptions.maxTokens,
          })
        : this.model;

      return await retryWithBackoff(async () => {
        // We pass the prompt as a single HumanMessage.
        // The RAG System Prompt formatting happens before this call in the RAG service.
        const result = await modelWithConfig.invoke([new HumanMessage(prompt)]);

        // Handle different return types from LangChain (String or BaseMessage)
        if (typeof result.content === "string") {
          return result.content;
        } else if (Array.isArray(result.content)) {
          // Handle multimodal content response (fallback to text parts)
          return result.content
            .map((c: any) => ("text" in c ? c.text : ""))
            .join("");
        }
        return JSON.stringify(result.content);
      });
    } catch (error) {
      logger.error("Gemini API Error:", error);
      throw new AppError(502, "Failed to generate response from Gemini");
    }
  }

  async generateEmbedding(text: string): Promise<number[]> {
    // Delegate to the specialized EmbeddingService to ensure vector dimension consistency (768)
    return embeddingService.generateEmbedding(text);
  }
}

/**
 * Stub implementation for Replicate (Llama) to demonstrate swappability.
 */
class ReplicateProvider implements LLMProvider {
  async generateResponse(
    prompt: string,
    options?: LLMOptions
  ): Promise<string> {
    logger.warn("ReplicateProvider is a stub. Returning mock response.");
    return "Replicate support is coming soon. Please switch to Gemini provider.";
  }

  async generateEmbedding(text: string): Promise<number[]> {
    return embeddingService.generateEmbedding(text);
  }
}

/**
 * Factory function to create the appropriate LLM provider based on environment configuration.
 */
export const createLLMProvider = (): LLMProvider => {
  const provider = env.LLM_PROVIDER || "gemini";

  logger.info(`Initializing LLM Provider: ${provider}`);

  switch (provider.toLowerCase()) {
    case "gemini":
      return new GeminiProvider();
    case "replicate":
      return new ReplicateProvider();
    default:
      logger.warn(`Unknown LLM provider '${provider}', falling back to Gemini`);
      return new GeminiProvider();
  }
};
