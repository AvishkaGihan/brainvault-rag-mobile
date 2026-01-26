import { Timestamp, FieldValue } from "firebase-admin/firestore";

/**
 * Document status enum
 * Matches Firestore document.status field
 */
export type DocumentStatus = "uploading" | "processing" | "ready" | "error";

/**
 * Document entity (Firestore schema)
 * AC6: User isolation and data association
 */
export interface Document {
  id: string;
  userId: string;
  title: string;
  fileName: string;
  fileSize: number; // Bytes (PDF) or character count (text)
  pageCount: number;
  status: DocumentStatus;
  storagePath?: string; // Firebase Storage path (PDF only)
  content?: string; // Text content (text documents only)
  errorMessage?: string;
  cancelRequestedAt?: Timestamp; // Cancellation intent timestamp
  extractedAt?: Timestamp; // When extraction completed
  extractionDuration?: number; // Processing time in ms
  textPreview?: string; // First 200 chars for display
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

/**
 * DTO for creating new documents
 * Uses FieldValue.serverTimestamp() for timestamps
 */
export interface CreateDocumentDTO {
  id: string;
  userId: string;
  title: string;
  fileName: string;
  fileSize: number;
  pageCount: number;
  status: DocumentStatus;
  storagePath?: string;
  content?: string;
  createdAt: FieldValue;
  updatedAt: FieldValue;
}

/**
 * API response for document creation
 * AC1, AC3: Response format
 */
export interface DocumentUploadResponse {
  success: true;
  data: {
    documentId: string;
    status: DocumentStatus;
    title: string;
    createdAt: string; // ISO 8601 string
  };
}

/**
 * API response data for document status checks
 * AC2: Status endpoint response shape
 */
export interface DocumentStatusResponse {
  documentId: string;
  status: DocumentStatus;
  progress?: number;
  processingStage?: string;
  errorMessage?: string;
  updatedAt: string; // ISO 8601 string
}

/**
 * Request body for text document creation
 * AC3: Text document endpoint
 */
export interface CreateTextDocumentRequest {
  title: string;
  content: string;
  source?: "paste" | "import"; // Optional metadata
}

/**
 * Chunked text with metadata for embedding generation
 * Used by Story 3.5 (Chunking) → Story 3.6 (Embedding)
 */
export interface ChunkedDocument {
  documentId: string;
  userId: string;
  chunks: TextChunk[];
}

export interface TextChunk {
  text: string; // The actual chunk text content
  pageNumber: number; // Source page (for citation)
  chunkIndex: number; // Sequential position (0-based)
  textPreview: string; // First 200 chars for display
}
