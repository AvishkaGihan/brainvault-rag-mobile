/**
 * Chat Controller
 * Story 5.4: RAG query endpoint
 */

import { Request, Response, NextFunction } from "express";
import { RagQueryService } from "../services/rag-query.service";
import { ValidationError } from "../types/api.types";
import type { ApiResponse } from "../types/api.types";
import type {
  ChatQueryRequest,
  ChatQueryResponseData,
} from "../types/chat.types";
import { getCurrentTimestamp } from "../utils/helpers";

export class ChatController {
  private ragQueryService = new RagQueryService();

  /**
   * POST /api/v1/documents/:documentId/chat
   * Validate request and run RAG query
   */
  queryDocumentChat = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      const { documentId } = req.params;
      const { question } = req.body as ChatQueryRequest;

      if (!documentId || documentId.trim().length === 0) {
        throw new ValidationError("Invalid documentId", { documentId });
      }

      if (typeof question !== "string" || question.trim().length === 0) {
        throw new ValidationError("Question is required", {
          field: "question",
        });
      }

      const userId = req.user!.uid;

      const result = await this.ragQueryService.queryDocument({
        userId,
        documentId,
        question: question.trim(),
      });

      const timestamp = getCurrentTimestamp();
      const response: ApiResponse<ChatQueryResponseData> = {
        success: true,
        data: result,
        meta: { timestamp },
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  };
}
