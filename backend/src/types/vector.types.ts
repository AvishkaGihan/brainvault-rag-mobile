/**
 * Vector Database Type Definitions
 * Story 1.4: Configure Pinecone Vector Database
 *
 * Defines metadata schema and types for vector storage in Pinecone
 */

/**
 * VectorMetadata: Complete metadata for stored embeddings
 *
 * All fields are required and used for:
 * 1. User data isolation (userId filtering)
 * 2. Document attribution and tracking
 * 3. Source citation in chat responses
 * 4. Chunk sequencing and context window ordering
 *
 * Storage Limits:
 * - Pinecone free tier: ~40KB per vector
 * - Max 10 metadata fields per vector (currently using 5)
 *
 * Security Note:
 * - userId field is CRITICAL for user data isolation
 * - All queries MUST include userId filter to prevent cross-user data leakage
 * - documentId ensures users can only access their uploaded documents
 *
 * Note: Must extend Record<string, any> to be compatible with Pinecone SDK
 */
export interface VectorMetadata extends Record<string, any> {
  /**
   * userId (string): User ID for isolation
   * - Format: UUID or Firebase Auth UID
   * - Purpose: Primary isolation mechanism for user privacy
   * - Example: "user-abc123def456"
   *
   * SECURITY: All vector queries must filter by userId
   * Failure to filter by userId could expose other users' documents
   */
  userId: string;

  /**
   * documentId (string): Unique document identifier
   * - Format: UUID or Firebase Firestore document ID
   * - Purpose: Links vectors back to source document
   * - Example: "doc-xyz789uvw012"
   *
   * Used for:
   * - Document deletion (delete all vectors for a document)
   * - Source attribution in chat citations
   * - Document metadata retrieval
   */
  documentId: string;

  /**
   * pageNumber (number): Source page number (0-indexed or 1-indexed)
   * - Format: Integer >= 0 (or 1 for 1-indexed)
   * - Purpose: Source attribution - shown in chat UI as "Page X"
   * - Example: 0 (first page), 15 (16th page)
   *
   * Used for:
   * - Displaying citation: "According to Page 5 of document..."
   * - Multi-document queries: helping user identify source
   * - Optional: Could support page range in future (currentPage, maxPage)
   */
  pageNumber: number;

  /**
   * chunkIndex (number): Sequential chunk order within document
   * - Format: Integer >= 0 (0-indexed)
   * - Purpose: Maintains chunk sequencing for context window assembly
   * - Example: 0 (first chunk), 42 (43rd chunk)
   *
   * Used for:
   * - Context window assembly: combine chunks in order
   * - Overlap detection: avoid duplicating adjacent chunks
   * - Future: Could support token count and window sliding logic
   */
  chunkIndex: number;

  /**
   * textPreview (string): First 200 characters of chunk text
   * - Format: Plain text (no formatting)
   * - Max length: 200 characters (enforced by application, not Pinecone)
   * - Purpose: Display preview in UI without fetching full text
   * - Example: "The theory of relativity is a central concept in physics..."
   *
   * Used for:
   * - Quick preview in source citations
   * - UI display without additional database lookup
   * - Debugging: verify correct content was retrieved
   *
   * Note: NOT used for filtering/search, only display purposes
   * Optimization: Consider truncating at nearest sentence boundary
   */
  textPreview: string;
}

/**
 * VectorStorageRequest: Request payload for upserting vectors
 * Used when storing document embeddings in Pinecone
 */
export interface VectorStorageRequest {
  id: string; // Vector ID (typically `${documentId}_${chunkIndex}`)
  values: number[]; // 768-dimensional embedding vector
  metadata: VectorMetadata;
}

/**
 * VectorQueryResult: Result from querying similar vectors
 * Returned by Pinecone similarity search with metadata
 */
export interface VectorQueryResult {
  id: string;
  score: number; // Similarity score (0-1)
  metadata: VectorMetadata;
}

/**
 * VectorQueryFilter: Metadata filter criteria for queries
 * Used to filter vectors before similarity search
 */
export interface VectorQueryFilter {
  userId: string; // REQUIRED: User isolation
  documentId?: string; // Optional: Limit to specific document
}
