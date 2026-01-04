/**
 * Document Entity & Processing Types
 * This file defines the core Document entity structure used across the application,
 * mirroring the Firestore data model and API responses. It also includes types
 * related to file upload and asynchronous processing status.
 */

// ------------------------------------------------------------------
// Core Document Entity
// ------------------------------------------------------------------

/**
 * Represents a user-uploaded PDF document and its processing state.
 * Mirrors the Firestore document structure at `/users/{userId}/documents/{documentId}`.
 */
export interface Document {
  /** Unique identifier for the document (UUID or Firestore ID) */
  id: string;

  /** ID of the user who owns this document */
  userId: string;

  /** Current processing status of the document */
  status: DocumentStatus;

  /**
   * The original name of the uploaded file.
   * Used for display in the UI.
   */
  name: string;

  /**
   * The name of the file on the storage system.
   * May differ from `name` to ensure uniqueness or sanitized formatting.
   */
  storagePath: string;

  /** File size in bytes */
  fileSize: number;

  /** MIME type of the file (e.g., 'application/pdf') */
  mimeType: string;

  /** Number of pages in the PDF (available after processing) */
  pageCount?: number;

  /**
   * Pinecone namespace where vectors for this document are stored.
   * Usually formatted as `user_{userId}` or specific to document.
   */
  vectorNamespace?: string;

  /** Number of vector chunks generated from this document */
  chunkCount?: number;

  /** Current progress of processing (0-100) */
  processingProgress: number;

  /** Human-readable description of the current processing stage */
  processingStage?: string;

  /** Error message if status is 'error' */
  errorMessage?: string;

  /** ISO 8601 timestamp of creation */
  createdAt: Date | string;

  /** ISO 8601 timestamp of last update */
  updatedAt: Date | string;
}

// ------------------------------------------------------------------
// Status Types
// ------------------------------------------------------------------

/**
 * Valid states for a document's lifecycle.
 */
export type DocumentStatus = "uploading" | "processing" | "ready" | "error";

/**
 * Payload for status update events or polling responses.
 */
export interface ProcessingStatus {
  /** Current status */
  status: DocumentStatus;

  /** Progress percentage (0-100) */
  progress: number;

  /** Description of what is currently happening */
  stage: string;

  /** Optional error details if failed */
  error?: string;
}

// ------------------------------------------------------------------
// Upload Types
// ------------------------------------------------------------------

/**
 * Metadata associated with a file upload request.
 */
export interface UploadMetadata {
  /** Original file name */
  originalName: string;

  /** Mime type */
  mimeType: string;

  /** Size in bytes */
  size: number;
}

/**
 * Metadata stored with vector embeddings in Pinecone.
 */
export interface VectorMetadata {
  documentId: string;
  documentName: string;
  pageNumber: number;
  chunkIndex: number;
  text: string;
  userId: string;
}

// ------------------------------------------------------------------
// Chunk Types
// ------------------------------------------------------------------

/**
 * Represents a text chunk produced during document processing.
 * Includes the raw text and metadata used for citations and vector storage.
 */
export interface ChunkWithMetadata {
  /** Raw chunk text */
  text: string;
  /** Metadata describing the chunk */
  metadata: {
    /** Optional original document name (if available at chunking time) */
    documentName?: string;
    /** 1-based page number where this chunk begins */
    pageNumber: number;
    /** Sequential chunk index within the full document */
    chunkIndex: number;
    /** Start character offset within the original text */
    startOffset: number;
    /** End character offset within the original text */
    endOffset: number;
  };
}
