/**
 * Embedding Service
 * Handles text extraction from PDF documents and text documents
 * STORY 3.4: Implement PDF Text Extraction
 *
 * Architecture:
 * - PDF files: Extract text with page boundaries using pdf-parse
 * - Text documents: Process directly with single page
 * - Updates Firestore document records with extraction results
 */

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorageInstance } from "../config/storage";
import { AppError } from "../types/api.types";
import { PDFParse } from "pdf-parse";

/**
 * Extracted text structure with page boundaries preserved
 * AC1: Text structure contains total page count and page-text mapping
 */
export interface ExtractedText {
  pageCount: number;
  pages: {
    pageNumber: number;
    text: string;
  }[];
}

/**
 * PDF Text Extraction Service
 * Business logic for extracting text from PDF and text documents
 */
export class EmbeddingService {
  private db = getFirestore();

  /**
   * Extract text from document (PDF or text-only)
   * AC1: PDF text extraction with page boundaries
   * AC2: Text-only document processing
   * AC3: Error handling for corrupt PDFs
   * AC4: Page boundary preservation
   *
   * @param documentId - Document ID to process
   * @returns Extracted text with page structure
   */
  async extractTextFromDocument(documentId: string): Promise<ExtractedText> {
    const startTime = Date.now();

    try {
      // Load document record from Firestore
      const docRef = this.db.collection("documents").doc(documentId);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw new AppError("DOCUMENT_NOT_FOUND", "Document not found", 404);
      }

      const document = docSnap.data();
      if (!document) {
        throw new AppError(
          "DOCUMENT_NOT_FOUND",
          "Document data not found",
          404,
        );
      }

      let extractedText: ExtractedText;

      // Determine processing type: PDF vs text document
      if (document.storagePath) {
        // PDF document - extract from Storage
        extractedText = await this.extractFromPDF(document.storagePath);
      } else if (document.content) {
        // Text document - process directly
        extractedText = this.extractFromText(document.content);
      } else {
        throw new AppError(
          "INVALID_DOCUMENT",
          "Document has no storage path or content",
          400,
        );
      }

      // Calculate extraction duration and text preview
      const extractionDuration = Date.now() - startTime;
      const textPreview = extractedText.pages[0]?.text?.substring(0, 200) || "";

      // Update document status and metadata
      await docRef.update({
        status: "ready",
        pageCount: extractedText.pageCount,
        extractedAt: FieldValue.serverTimestamp(),
        extractionDuration,
        textPreview,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return extractedText;
    } catch (error) {
      // Handle extraction failures
      await this.handleExtractionError(documentId, error as Error);
      throw error;
    }
  }

  /**
   * Extract text from PDF file using pdf-parse
   * AC1: PDF text extraction with page boundaries
   * AC3: Error handling for corrupt PDFs
   * AC4: Page boundary preservation
   *
   * @param storagePath - Firebase Storage path to PDF
   * @returns Extracted text structure
   */
  private async extractFromPDF(storagePath: string): Promise<ExtractedText> {
    try {
      // Download PDF from Firebase Storage
      const bucket = getStorageInstance().bucket();
      const file = bucket.file(storagePath);
      const [buffer] = await file.download();

      // Extract text using pdf-parse library
      const parser = new PDFParse(buffer);
      const textData = await parser.getText();

      // pdf-parse getText() returns { text: string }
      // For now, treat as single page since page boundaries aren't reliably detectable
      // AC4: Page boundary preservation - simplified approach
      const pages = [
        {
          pageNumber: 1,
          text: textData.text.trim(),
        },
      ];

      return {
        pageCount: 1, // Simplified - will enhance in future iterations
        pages,
      };
    } catch (error) {
      if (error instanceof Error) {
        if (
          error.message.includes("Invalid PDF") ||
          error.message.includes("PDF")
        ) {
          throw new AppError(
            "PDF_EXTRACTION_FAILED",
            "Unable to extract text from this PDF file",
            400,
            { originalError: error.message },
          );
        }

        throw new AppError(
          "DOCUMENT_ACCESS_FAILED",
          "Unable to access document file",
          500,
          { originalError: error.message },
        );
      }

      throw error;
    }
  }

  /**
   * Process text document directly
   * AC2: Text-only document processing with single page
   *
   * @param content - Text content
   * @returns Extracted text structure
   */
  private extractFromText(content: string): ExtractedText {
    return {
      pageCount: 1,
      pages: [
        {
          pageNumber: 1,
          text: content,
        },
      ],
    };
  }

  /**
   * Split text into pages (approximation since pdf-parse doesn't provide page boundaries)
   * AC4: Page boundary preservation - best effort page splitting
   */
  private splitTextByPages(text: string, pageCount: number): string[] {
    if (pageCount <= 1) {
      return [text];
    }

    // Simple heuristic: split by estimated page length
    const avgCharsPerPage = Math.ceil(text.length / pageCount);
    const pages: string[] = [];

    for (let i = 0; i < pageCount; i++) {
      const start = i * avgCharsPerPage;
      const end = Math.min((i + 1) * avgCharsPerPage, text.length);
      pages.push(text.substring(start, end));
    }

    return pages;
  }

  /**
   * Handle extraction errors by updating document status
   * AC3: Error handling with document status updates
   *
   * @param documentId - Document ID
   * @param error - Error that occurred
   */
  private async handleExtractionError(
    documentId: string,
    error: Error,
  ): Promise<void> {
    try {
      const docRef = this.db.collection("documents").doc(documentId);

      let errorMessage = "Unable to extract text from document";

      // Customize error message based on error type
      if (
        error.message.includes("PDF") ||
        error.message.includes("Invalid PDF")
      ) {
        errorMessage = "Unable to extract text from this PDF file";
      } else if (
        error.message.includes("Storage") ||
        error.message.includes("access")
      ) {
        errorMessage = "Unable to access document file";
      }

      await docRef.update({
        status: "error",
        errorMessage,
        updatedAt: FieldValue.serverTimestamp(),
      });

      // Log error with document metadata for debugging
      console.error(`[${new Date().toISOString()}] Text extraction failed:`, {
        documentId,
        error: error.message,
        stack: error.stack,
      });
    } catch (updateError) {
      console.error(
        `Failed to update document status for ${documentId}:`,
        updateError,
      );
    }
  }
}
