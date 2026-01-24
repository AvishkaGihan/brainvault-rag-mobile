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
 * POST /api/v1/documents/text
 * Create text-only document
 * AC3: JSON body with title and content
 * AC5: Authentication via middleware (applied at router level)
 */
router.post("/text", documentController.createTextDocument);

export { router as documentRoutes };
