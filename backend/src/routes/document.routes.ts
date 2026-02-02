import { Router } from "express";
import { DocumentController } from "../controllers/document.controller";
import { upload, handleMulterError } from "../middleware/upload.middleware";

const router = Router();
const documentController = new DocumentController();

/**
 * POST /api/v1/documents/upload
 * Upload PDF document
 * AC1: Multipart form-data with file validation
 * AC5: Authentication via middleware (applied at router level)
 */
router.post(
  "/upload",
  upload.single("file"), // Multer middleware expects 'file' field
  handleMulterError, // Transform Multer errors to AppError
  documentController.uploadPDF,
);

/**
 * GET /api/v1/documents
 * List documents for authenticated user
 * Story 4.1: Document list screen
 */
router.get("/", documentController.listDocuments);

/**
 * POST /api/v1/documents/:documentId/cancel
 * Cancel document upload or processing
 * Story 3.9: Upload cancellation
 */
router.post("/:documentId/cancel", documentController.cancelDocument);

/**
 * POST /api/v1/documents/text
 * Create text-only document
 * AC3: JSON body with title and content
 * AC5: Authentication via middleware (applied at router level)
 */
router.post("/text", documentController.createTextDocument);

/**
 * GET /api/v1/documents/:documentId/status
 * Get document processing status
 * AC2: Status endpoint with user isolation
 */
router.get("/:documentId/status", documentController.getDocumentStatus);

/**
 * DELETE /api/v1/documents/:documentId
 * Delete document and all associated data
 * Story 4.5: Document Deletion
 * AC8: Ownership validation, AC9: Complete cleanup
 */
router.delete("/:documentId", documentController.deleteDocument);

export { router as documentRoutes };
