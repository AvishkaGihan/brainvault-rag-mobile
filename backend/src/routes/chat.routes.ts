import { Router } from "express";
import { ChatController } from "../controllers/chat.controller";

const router = Router({ mergeParams: true });
const chatController = new ChatController();

/**
 * POST /api/v1/documents/:documentId/chat
 * Chat query endpoint (mounted at /api/v1/documents/:documentId/chat)
 */
router.post("/", chatController.queryDocumentChat);

/**
 * POST /api/v1/documents/:documentId/chat/stream
 * Streaming chat endpoint (mounted at /api/v1/documents/:documentId/chat)
 */
router.post("/stream", chatController.streamDocumentChat);

/**
 * GET /api/v1/documents/:documentId/chat/history
 * Load recent or paginated chat history
 */
router.get("/history", chatController.getChatHistory);

export { router as chatRoutes };
