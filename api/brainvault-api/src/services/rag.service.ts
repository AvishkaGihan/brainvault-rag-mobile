import { getIndex } from "../config/pinecone";
import { embeddingService } from "./embedding.service";
import { createLLMProvider, RAG_SYSTEM_PROMPT_TEMPLATE } from "./llm.service";
import { documentService } from "./document.service";
import { ChatSessionModel } from "../models/chat-session.model";
import { MessageModel } from "../models/message.model";
import { extractCitations } from "../utils/citations";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";
import { ChatResponse } from "../types/chat.types";

export class RAGService {
  /**
   * Orchestrates the RAG pipeline:
   * 1. Embed query
   * 2. Retrieve relevant chunks
   * 3. Augment prompt
   * 4. Generate LLM response
   * 5. Extract citations
   * 6. Persist conversation
   *
   * @param documentId The document to query against
   * @param userId The user asking the question
   * @param message The user's query text
   * @param sessionId Optional existing session ID
   */
  async query(
    documentId: string,
    userId: string,
    message: string,
    sessionId?: string
  ): Promise<ChatResponse> {
    try {
      logger.info(`Starting RAG query for doc ${documentId} by user ${userId}`);
      // 0. Validation & Setup
      // Verify document existence and get name for citations
      const document = await documentService.getDocument(documentId, userId);
      // Manage Session
      const session = await ChatSessionModel.createSession(
        userId,
        documentId,
        sessionId
      );
      const currentSessionId = session.id!;
      // Persist User Message (Optimistic)
      const userMessageEntry = await MessageModel.create(
        userId,
        documentId,
        currentSessionId,
        {
          chatId: currentSessionId,
          role: "user",
          content: message,
        }
      );
      // -----------------------------------------------------------------------
      // Stage 1: Embed Query
      // -----------------------------------------------------------------------
      const queryEmbedding = await embeddingService.generateEmbedding(message);
      // -----------------------------------------------------------------------
      // Stage 2: Retrieve Context (Pinecone)
      // -----------------------------------------------------------------------
      const index = getIndex();
      const namespace = `user_${userId}`;
      const queryResponse = await index.namespace(namespace).query({
        vector: queryEmbedding,
        topK: 3,
        filter: { documentId: { $eq: documentId } },
        includeMetadata: true,
      });
      const matches = queryResponse.matches || [];
      // Filter by similarity threshold (0.7 as per blueprint)
      const relevantChunks = matches.filter(
        (match) => (match.score ?? 0) > 0.7
      );
      if (relevantChunks.length === 0) {
        logger.info(`No relevant chunks found for query in doc ${documentId}`);
        // Fallback response for no context
        const fallbackContent =
          "I couldn't find relevant information about that in this document.";
        // Persist Assistant Message
        const assistantMessageEntry = await MessageModel.create(
          userId,
          documentId,
          currentSessionId,
          {
            chatId: currentSessionId,
            role: "assistant",
            content: fallbackContent,
            citations: [],
          }
        );
        // Update session stats
        await ChatSessionModel.updateMessageCount(
          userId,
          documentId,
          currentSessionId,
          2
        ); // +2 for user and assistant
        return {
          sessionId: currentSessionId,
          message: assistantMessageEntry,
        };
      }
      // -----------------------------------------------------------------------
      // Stage 3: Augment Prompt
      // -----------------------------------------------------------------------
      const contextText = relevantChunks
        .map((match) => {
          const meta = match.metadata as any;
          // Format: "...text... [Page X]" to help LLM cite correctly
          return `${meta.text} [Page ${meta.pageNumber}]`;
        })
        .join("\n\n");
      const finalPrompt = RAG_SYSTEM_PROMPT_TEMPLATE.replace(
        "{context}",
        contextText
      ).replace("{question}", message);
      // -----------------------------------------------------------------------
      // Stage 4: Generate Response (LLM)
      // -----------------------------------------------------------------------
      let llmResponseText: string;
      try {
        const llmProvider = createLLMProvider();
        llmResponseText = await llmProvider.generateResponse(finalPrompt);
      } catch (llmError) {
        logger.error("LLM Generation failed", llmError);
        // Record error message
        await MessageModel.create(userId, documentId, currentSessionId, {
          chatId: currentSessionId,
          role: "assistant",
          content:
            "I'm having trouble generating an answer right now. Please try again.",
          isError: true,
          errorMessage: "LLM Provider Unavailable",
        });

        throw new AppError(502, "AI service temporarily unavailable");
      }
      // -----------------------------------------------------------------------
      // Stage 5: Extract Citations
      // -----------------------------------------------------------------------
      // Pass the Pinecone matches directly to extractCitations
      // The utility expects ScoredPineconeRecord[] with metadata containing pageNumber
      const citations = extractCitations(relevantChunks, document.name);
      // -----------------------------------------------------------------------
      // Persist Assistant Response
      // -----------------------------------------------------------------------
      const assistantMessageEntry = await MessageModel.create(
        userId,
        documentId,
        currentSessionId,
        {
          chatId: currentSessionId,
          role: "assistant",
          content: llmResponseText,
          citations: citations,
        }
      );
      await ChatSessionModel.updateMessageCount(
        userId,
        documentId,
        currentSessionId,
        2
      );
      return {
        sessionId: currentSessionId,
        message: assistantMessageEntry,
      };
    } catch (error) {
      logger.error("RAG Query Error", error);
      if (error instanceof AppError) throw error;
      throw new AppError(500, "Failed to process query");
    }
  }
}

export const ragService = new RAGService();
