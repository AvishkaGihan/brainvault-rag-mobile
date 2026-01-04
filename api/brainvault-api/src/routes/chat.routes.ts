import { Router, Response } from "express";
import { authenticateToken } from "../middleware/auth";
import { validate } from "../middleware/validate";
import {
  chatRequestSchema,
  sessionIdSchema,
} from "../validators/chat.validator";
import { documentIdSchema } from "../validators/document.validator";
import { ragService } from "../services/rag.service";
import { documentService } from "../services/document.service";
import { AuthenticatedRequest } from "../types/user.types";
import { db } from "../config/firebase";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";

const router = Router({ mergeParams: true });

// Apply authentication middleware to all routes
router.use(authenticateToken);

/**

* POST /:id/chat
* Send a message to the RAG system for a specific document.
* Flow:
* 1. Validate inputs (document ID, message content).


* 2. RAG Service handles:


* * Document ownership verification


* * Session management (creates or retrieves)


* * Embedding generation & Vector search


* * LLM generation


* * Message persistence


* 3. Return the assistant's response with citations.
*/
router.post(
  "/:id/chat",
  validate(documentIdSchema),
  validate(chatRequestSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const documentId = req.params.id;
      const { message, sessionId } = req.body;
      // Delegate complex RAG logic to the service
      // ragService.query() internally verifies document ownership via documentService
      const response = await ragService.query(
        documentId,
        userId,
        message,
        sessionId
      );
      res.status(200).json({
        success: true,
        data: response,
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Chat request failed for doc ${req.params.id}`, error);
      throw new AppError(
        500,
        "CHAT_REQUEST_FAILED",
        "Failed to process chat message"
      );
    }
  }
);

/**

* GET /:id/chat/history
* Retrieve chat history for a document.
* Supports filtering by sessionId and pagination/limiting.
*/
router.get(
  "/:id/chat/history",
  validate(documentIdSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const documentId = req.params.id;
      const sessionId = req.query.sessionId as string | undefined;
      const limit = parseInt(req.query.limit as string) || 50;
      // 1. Verify ownership
      await documentService.getDocument(documentId, userId);
      // 2. Query Firestore for messages
      let query = db
        .collection("messages")
        .where("documentId", "==", documentId)
        .where("userId", "==", userId);
      if (sessionId) {
        query = query.where("chatId", "==", sessionId);
      }
      // Order by creation time (oldest first for chat history)
      // Note: This requires a composite index in Firestore (userId + documentId + createdAt)
      query = query.orderBy("createdAt", "asc").limit(limit);
      const snapshot = await query.get();
      const messages = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        // Ensure dates are serialized properly
        createdAt: doc.data().createdAt?.toDate().toISOString(),
      }));
      res.status(200).json({
        success: true,
        data: {
          messages,
        },
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Failed to fetch chat history for ${req.params.id}`, error);
      throw new AppError(
        500,
        "CHAT_HISTORY_FAILED",
        "Failed to retrieve chat history"
      );
    }
  }
);

/**

* DELETE /:id/chat
* Clear chat history for a document.
* If sessionId is provided, clears only that session.
* Otherwise, clears all chat history for the document.
*/
router.delete(
  "/:id/chat",
  validate(documentIdSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const documentId = req.params.id;
      const sessionId = req.query.sessionId as string | undefined;
      // 1. Verify ownership
      await documentService.getDocument(documentId, userId);
      // 2. Prepare deletion query
      const batch = db.batch();
      let deletedCount = 0;
      // Delete Messages
      let messagesQuery = db
        .collection("messages")
        .where("documentId", "==", documentId)
        .where("userId", "==", userId);
      if (sessionId) {
        messagesQuery = messagesQuery.where("chatId", "==", sessionId);
      }
      const messagesSnapshot = await messagesQuery.get();
      messagesSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        deletedCount++;
      });
      // Delete Session(s) Metadata
      // If we are deleting all history, we should also remove the session records
      let sessionsQuery = db
        .collection("chats")
        .where("documentId", "==", documentId)
        .where("userId", "==", userId);
      if (sessionId) {
        sessionsQuery = sessionsQuery.where("**name**", "==", sessionId); // **name** checks doc ID
      }
      const sessionsSnapshot = await sessionsQuery.get();
      sessionsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      // Commit batch
      if (deletedCount > 0 || !sessionsSnapshot.empty) {
        await batch.commit();
        logger.info(
          `Cleared chat history for doc ${documentId}. Deleted ${deletedCount} messages.`
        );
      }
      res.status(200).json({
        success: true,
        data: {
          deleted: true,
        },
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Failed to clear chat history for ${req.params.id}`, error);
      throw new AppError(
        500,
        "CHAT_CLEAR_FAILED",
        "Failed to clear chat history"
      );
    }
  }
);

export const chatRoutes = router;
