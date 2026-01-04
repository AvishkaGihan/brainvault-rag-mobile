import { Router, Response } from "express";
import { authenticateToken } from "../middleware/auth";
import { upload } from "../middleware/upload";
import { validate } from "../middleware/validate";
import {
  uploadDocumentSchema,
  documentIdSchema,
} from "../validators/document.validator";
import { documentService } from "../services/document.service";
import { ingestionService } from "../services/ingestion.service";
import { AuthenticatedRequest } from "../types/user.types";
import { AppError } from "../errors/app-error";
import { logger } from "../config/logger";

const router = Router();

// Apply authentication middleware to all routes in this router
router.use(authenticateToken);

/**

* GET /
* List all documents for the authenticated user.
* Ordered by creation date descending (newest first).
*/
router.get("/", async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.user!.uid;
    const documents = await documentService.listDocuments(userId);
    res.status(200).json({
      success: true,
      data: {
        documents,
      },
    });
  } catch (error) {
    logger.error("Failed to list documents", error);
    throw new AppError(
      500,
      "LIST_DOCUMENTS_FAILED",
      "Failed to retrieve documents"
    );
  }
});

/**

* POST /
* Upload a new PDF document.
* 1. Validates file presence and type (via upload middleware).


* 2. Creates initial document record in Firestore.


* 3. Triggers async ingestion process (background task).


* 4. Returns document metadata immediately.
*/
router.post(
  "/",
  upload.single("file"), // Handle multipart/form-data
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      if (!req.file) {
        throw new AppError(400, "FILE_REQUIRED", "File is required");
      }
      // Validate file metadata against strict rules
      // Note: We construct a validation object that matches the Zod schema expectation
      await uploadDocumentSchema.parseAsync({
        file: {
          mimetype: req.file.mimetype,
          size: req.file.size,
          originalname: req.file.originalname,
        },
      });
      const userId = req.user!.uid;
      const { originalname, size, path: filePath } = req.file;
      // 1. Create Metadata Record
      const newDoc = await documentService.createDocument(
        userId,
        originalname,
        size,
        filePath
      );
      // 2. Trigger Background Ingestion (Fire & Forget)
      // We do NOT await this. The client polls /status to track progress.
      ingestionService
        .processDocument(newDoc.id, filePath)
        .catch((err) =>
          logger.error(`Background ingestion failed for doc ${newDoc.id}`, err)
        );
      logger.info(`Document upload started: ${newDoc.id}`);
      res.status(201).json({
        success: true,
        data: {
          document: newDoc,
        },
      });
    } catch (error) {
      logger.error("Document upload failed", error);
      // Clean up uploaded file if validation failed BEFORE service call
      // (Ingestion service handles cleanup during processing errors)
      if (req.file && error instanceof AppError) {
        // In a real app, we might want to unlink the file here to prevent accumulation
      }
      throw error; // Let global handler process it
    }
  }
);

/**

* GET /:id
* Retrieve a specific document by ID.
* Enforces ownership check.
*/
router.get(
  "/:id",
  validate(documentIdSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const { id } = req.params;
      const document = await documentService.getDocument(id, userId);
      res.status(200).json({
        success: true,
        data: {
          document,
        },
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Failed to get document ${req.params.id}`, error);
      throw new AppError(
        500,
        "GET_DOCUMENT_FAILED",
        "Failed to retrieve document"
      );
    }
  }
);

/**

* GET /:id/status
* Polling endpoint for document processing status.
* Used by mobile app to show progress bars.
*/
router.get(
  "/:id/status",
  validate(documentIdSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const { id } = req.params;
      const document = await documentService.getDocument(id, userId);
      res.status(200).json({
        success: true,
        data: {
          status: document.status,
          progress: document.processingProgress,
          stage: document.processingStage,
          errorMessage: document.errorMessage || null,
        },
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Failed to get status for ${req.params.id}`, error);
      throw new AppError(
        500,
        "GET_DOCUMENT_STATUS_FAILED",
        "Failed to retrieve document status"
      );
    }
  }
);

/**

* DELETE /:id
* Delete a document and all associated data (storage, vectors).
*/
router.delete(
  "/:id",
  validate(documentIdSchema),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.uid;
      const { id } = req.params;
      await documentService.deleteDocument(id, userId);
      res.status(200).json({
        success: true,
        data: {
          deleted: true,
        },
      });
    } catch (error) {
      if (error instanceof AppError) throw error;
      logger.error(`Failed to delete document ${req.params.id}`, error);
      throw new AppError(
        500,
        "DELETE_DOCUMENT_FAILED",
        "Failed to delete document"
      );
    }
  }
);

export const documentsRoutes = router;
