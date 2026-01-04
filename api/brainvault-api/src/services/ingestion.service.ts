import fs from "fs";
const pdf = require("pdf-parse");
import { documentService } from "./document.service";
import { embeddingService } from "./embedding.service";
import { chunkText } from "../utils/chunker";
import { cleanupTempFile } from "../utils/file";
import { logger } from "../config/logger";
import { AppError } from "../errors/app-error";

export class IngestionService {
  /**

* Orchestrates the complete document ingestion pipeline.
* 1. Extract Text


* 2. Chunk Text


* 3. Generate Embeddings


* 4. Store Vectors


* @param documentId The unique ID of the document (Firestore ID).
* @param filePath Local path to the uploaded PDF file.
*/
  async processDocument(documentId: string, filePath: string): Promise<void> {
    const PAGE_BREAK_MARKER = "[[**PAGE_BREAK**]]";

    try {
      logger.info(`Starting ingestion for document ${documentId}`);

      // -----------------------------------------------------------------------
      // Stage 1: Text Extraction (10%)
      // -----------------------------------------------------------------------
      await documentService.updateStatus(
        documentId,
        "processing",
        10,
        "Extracting text..."
      );

      const dataBuffer = await fs.promises.readFile(filePath);

      // Custom page render to preserve page boundaries for citation mapping
      const renderPage = (pageData: any) => {
        const render_options = {
          normalizeWhitespace: true,
          disableCombineTextItems: false,
        };
        return pageData
          .getTextContent(render_options)
          .then((textContent: any) => {
            let lastY,
              text = "";
            for (let item of textContent.items) {
              if (lastY == item.transform[5] || !lastY) {
                text += item.str;
              } else {
                text += "\n" + item.str;
              }
              lastY = item.transform[5];
            }
            return text + PAGE_BREAK_MARKER;
          });
      };

      let pdfData;
      try {
        pdfData = await pdf(dataBuffer, { pagerender: renderPage });
      } catch (parseError) {
        logger.error("PDF Parse failed", parseError);
        throw new AppError(
          422,
          "Failed to parse PDF file. Ensure it is a valid PDF."
        );
      }

      if (!pdfData || !pdfData.text) {
        throw new AppError(
          422,
          "Extracted text is empty. PDF might be an image scan."
        );
      }

      // Reconstruct text and calculate page breaks
      // pdf-parse joins pages with \n\n by default if we don't override,
      // but our custom renderer appended the marker.
      // We need to split, clean, and map offsets.
      const rawPages = pdfData.text.split(PAGE_BREAK_MARKER);
      // Remove the last empty element if marker was at the end
      if (rawPages.length > 0 && rawPages[rawPages.length - 1].trim() === "") {
        rawPages.pop();
      }

      let fullText = "";
      const pageBreaks: number[] = [];
      let currentOffset = 0;

      rawPages.forEach((pageText: string) => {
        // Record the start of this page
        pageBreaks.push(currentOffset);

        // Append text (ensuring we don't lose separation)
        fullText += pageText;
        currentOffset += pageText.length;
      });

      if (fullText.trim().length === 0) {
        throw new AppError(
          422,
          "Document contains no readable text (likely scanned images)."
        );
      }

      // -----------------------------------------------------------------------
      // Stage 2: Chunking (30%)
      // -----------------------------------------------------------------------
      await documentService.updateStatus(
        documentId,
        "processing",
        30,
        "Creating knowledge base..."
      );

      const chunks = await chunkText(fullText, pageBreaks);

      if (chunks.length === 0) {
        throw new AppError(
          422,
          "Could not generate any chunks from the document."
        );
      }

      // -----------------------------------------------------------------------
      // Stage 3: Embedding Generation (60%)
      // -----------------------------------------------------------------------
      await documentService.updateStatus(
        documentId,
        "processing",
        60,
        "Generating AI embeddings..."
      );

      // Need userId for storage; fetch document metadata to retrieve it
      // Note: We are inside a background process, so we assume the doc exists.
      // We pass a dummy userId to getDocument initially because we just want the record,
      // but getDocument enforces ownership. We need to fetch it as admin or just get the data.
      // However, documentService.getDocument requires userId.
      // A safer approach in this architectural pattern is to assume the caller validated permissions
      // OR we add a system-level get method.
      // Given the constraints, we'll try to get it.
      // WAIT: The blueprint for updateStatus does not require userId.
      // But storeEmbeddings DOES require userId.
      // We must retrieve the document from Firestore to know the owner.
      // We will access Firestore directly here or add a method to DocumentService?
      // Strict rule: "Do not modify DocumentService".
      // We can use the firestore instance from config to get the userId directly.
      // Or we can rely on DocumentService if we knew the userId.
      // The `processDocument` signature only has `documentId`.
      // I will fetch the doc directly using DocumentModel to get the userId.

      // Import needed to fetch owner
      const { db } = require("../config/firebase");
      const docSnap = await db.collection("documents").doc(documentId).get();
      if (!docSnap.exists) {
        throw new AppError(404, "Document record not found during processing");
      }
      const userId = docSnap.data()?.userId;
      if (!userId) {
        throw new AppError(500, "Document owner not found");
      }

      // Set document name in chunks metadata for better context if needed
      const documentName = docSnap.data()?.name;
      chunks.forEach((chunk) => (chunk.metadata.documentName = documentName));

      const embeddings = await embeddingService.generateBatchEmbeddings(chunks);

      // -----------------------------------------------------------------------
      // Stage 4: Vector Storage (80%)
      // -----------------------------------------------------------------------
      await documentService.updateStatus(
        documentId,
        "processing",
        80,
        "Storing vectors..."
      );

      await embeddingService.storeEmbeddings(
        documentId,
        userId,
        chunks,
        embeddings
      );

      // -----------------------------------------------------------------------
      // Completion (100%)
      // -----------------------------------------------------------------------
      await documentService.updateStatus(
        documentId,
        "ready",
        100,
        "Ready to chat"
      );

      logger.info(`Document ${documentId} processed successfully.`);
    } catch (error: any) {
      logger.error(`Ingestion failed for document ${documentId}`, error);

      // Determine error message
      let errorMessage = "Failed to process document";
      if (error instanceof AppError) {
        errorMessage = error.message;
      } else if (error.message) {
        errorMessage = error.message;
      }

      // Update status to error so UI shows it
      try {
        await documentService.updateStatus(
          documentId,
          "error",
          0,
          "Processing failed",
          errorMessage
        );
      } catch (statusError) {
        logger.error("Failed to update error status", statusError);
      }

      // We do NOT re-throw here because this is likely running as a background/async task
      // triggered by the controller. If we throw, it might crash the process or go unhandled.
      // The status update communicates the failure to the user.
    } finally {
      // -----------------------------------------------------------------------
      // Cleanup
      // -----------------------------------------------------------------------
      try {
        await cleanupTempFile(filePath);
      } catch (cleanupError) {
        logger.warn(`Failed to cleanup temp file ${filePath}`, cleanupError);
      }
    }
  }
}

export const ingestionService = new IngestionService();
