import { Request, Response, NextFunction } from "express";
import { DocumentService } from "../services/document.service";
import { AppError } from "../types/api.types";
import type {
  CreateTextDocumentRequest,
  DocumentUploadResponse,
} from "../types/document.types";

/**
 * Controller for document upload endpoints
 * Handles requests, delegates business logic to service layer
 * AC1, AC3, AC5: Request handlers for PDF and text document uploads
 */
export class DocumentController {
  private documentService = new DocumentService();

  /**
   * Handle PDF upload
   * AC1: POST /api/v1/documents/upload
   * AC5: Authentication required (verified by middleware)
   */
  uploadPDF = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      // AC5: req.user.uid populated by auth middleware (Story 2.7)
      const userId = req.user!.uid;

      // req.file populated by multer middleware
      if (!req.file) {
        throw new AppError("NO_FILE_PROVIDED", "No file uploaded", 400);
      }

      const document = await this.documentService.uploadPDFDocument(
        userId,
        req.file,
      );

      // AC1: Response format with 201 status
      const response: DocumentUploadResponse = {
        success: true,
        data: {
          documentId: document.id,
          status: document.status,
          title: document.title,
          createdAt: document.createdAt.toDate().toISOString(),
        },
      };

      res.status(201).json(response);
    } catch (error) {
      next(error); // Pass to error middleware
    }
  };

  /**
   * Handle text document creation
   * AC3: POST /api/v1/documents/text
   * AC5: Authentication required (verified by middleware)
   */
  createTextDocument = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      const userId = req.user!.uid;
      const { title, content } = req.body as CreateTextDocumentRequest;

      // Basic validation - detailed validation in service layer
      if (
        title === undefined ||
        title === null ||
        content === undefined ||
        content === null
      ) {
        throw new AppError(
          "MISSING_FIELDS",
          "Title and content are required",
          400,
          {
            missing: [
              title === undefined || title === null ? "title" : undefined,
              content === undefined || content === null ? "content" : undefined,
            ].filter(Boolean),
          },
        );
      }

      const document = await this.documentService.createTextDocument(
        userId,
        title,
        content,
      );

      // AC3: Response format with 201 status
      const response: DocumentUploadResponse = {
        success: true,
        data: {
          documentId: document.id,
          status: document.status,
          title: document.title,
          createdAt: document.createdAt.toDate().toISOString(),
        },
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  };
}
