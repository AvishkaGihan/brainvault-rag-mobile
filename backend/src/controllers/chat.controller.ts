/**
 * Chat Controller
 * Story 5.4: RAG query endpoint
 */

import { Request, Response, NextFunction } from "express";
import { RagQueryService } from "../services/rag-query.service";
import { RagQueryStreamService } from "../services/rag-query-stream.service";
import { AppError, ValidationError } from "../types/api.types";
import type { ApiResponse } from "../types/api.types";
import type {
  ChatQueryRequest,
  ChatQueryResponseData,
  ChatStreamDonePayload,
} from "../types/chat.types";
import { getCurrentTimestamp } from "../utils/helpers";

export class ChatController {
  private ragQueryService = new RagQueryService();
  private ragQueryStreamService = new RagQueryStreamService();

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

  /**
   * POST /api/v1/documents/:documentId/chat/stream
   * Stream chat response with SSE events
   */
  streamDocumentChat = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    let headersSent = false;
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

      res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");
      res.setHeader("X-Accel-Buffering", "no");
      res.flushHeaders?.();
      headersSent = true;

      const { stream, done } = await this.ragQueryStreamService.streamDocument({
        userId,
        documentId,
        question: question.trim(),
      });

      let clientClosed = false;
      req.on("close", () => {
        clientClosed = true;
      });

      if (stream) {
        for await (const chunk of stream) {
          if (clientClosed || res.writableEnded) {
            return;
          }
          if (chunk.length > 0) {
            this.writeSseEvent(res, "delta", { text: chunk });
          }
        }
      }

      if (!clientClosed && !res.writableEnded) {
        this.writeSseEvent(res, "done", done);
        res.end();
      }
    } catch (error) {
      if (headersSent || res.headersSent) {
        const errorPayload = this.resolveStreamError(error);
        if (!res.writableEnded) {
          this.writeSseEvent(res, "error", errorPayload);
          res.end();
        }
        return;
      }
      next(error);
    }
  };

  private writeSseEvent(
    res: Response,
    event: "delta" | "done" | "error",
    data:
      | ChatStreamDonePayload
      | { text: string }
      | { code: string; message: string },
  ): void {
    res.write(`event: ${event}\n`);
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  }

  private resolveStreamError(error: unknown): {
    code: string;
    message: string;
  } {
    if (error instanceof AppError) {
      return { code: error.code, message: error.message };
    }
    if (error instanceof Error) {
      return { code: "INTERNAL_SERVER_ERROR", message: error.message };
    }
    return { code: "INTERNAL_SERVER_ERROR", message: "Streaming failed" };
  }
}
