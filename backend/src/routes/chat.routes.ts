import { Router } from "express";
import { ChatController } from "../controllers/chat.controller";

const router = Router({ mergeParams: true });
const chatController = new ChatController();

/**
 * POST /api/v1/documents/:documentId/chat
 * Chat query endpoint (mounted at /api/v1/documents/:documentId/chat)
 */
router.post("/", chatController.queryDocumentChat);

export { router as chatRoutes };
