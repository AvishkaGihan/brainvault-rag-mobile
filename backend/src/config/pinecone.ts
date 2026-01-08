/**
 * Pinecone Vector Database Configuration
 * Initializes Pinecone client for vector storage and retrieval operations
 *
 * Story 1.4: Configure Pinecone Vector Database
 *
 * Metadata Schema:
 * - userId (string): User isolation - ensures users only see their vectors
 * - documentId (string): Document tracking - links vectors back to source
 * - pageNumber (number): Source attribution - shows "Page X" in chat UI
 * - chunkIndex (number): Sequence tracking - maintains chunk ordering
 * - textPreview (string): Display preview - first 200 chars for UI preview
 *
 * Configuration Requirements:
 * - Vector Dimension: 768 (matches text-embedding-004)
 * - Distance Metric: Cosine (optimal for semantic search)
 * - Index Name: brainvault-index (configurable via PINECONE_INDEX env var)
 * - Metadata Filtering: Essential for user data isolation
 */

import { Pinecone } from "@pinecone-database/pinecone";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

// Validate required environment variables at startup
const PINECONE_API_KEY = process.env.PINECONE_API_KEY;
const PINECONE_INDEX = process.env.PINECONE_INDEX;

if (!PINECONE_API_KEY) {
  throw new Error(
    "PINECONE_API_KEY environment variable is required but not set"
  );
}

if (!PINECONE_INDEX) {
  throw new Error(
    "PINECONE_INDEX environment variable is required but not set"
  );
}

/**
 * Initialize Pinecone client
 * Creates a new Pinecone client instance with API key authentication
 *
 * Error Handling:
 * - Validates API key and index name at startup (fail-fast)
 * - Graceful degradation: Pinecone initialization errors are logged
 * - Export null values if initialization fails (allows app to start in degraded mode)
 *
 * Throws: Error if environment variables missing, logs other initialization errors
 */
let pineconeInstance: Pinecone | undefined;

try {
  pineconeInstance = new Pinecone({
    apiKey: PINECONE_API_KEY,
  });
} catch (error) {
  console.error(
    "Failed to initialize Pinecone client:",
    error instanceof Error ? error.message : String(error)
  );
  console.error(
    "Vector database will be unavailable. Check PINECONE_API_KEY and network connectivity."
  );
}

export const pinecone = pineconeInstance;

/**
 * Default Pinecone index instance
 * Connects to the configured index for vector operations
 *
 * Used for:
 * - Upserting embeddings with metadata (Story 3.7)
 * - Querying vectors with userId filter (Story 5.4)
 * - Deleting vectors during document removal (Story 4.5)
 *
 * Performance Characteristics:
 * - Query latency: P95 < 100ms for typical metadata filters
 * - Batch upsert: up to 100 vectors per API call (rate-limited to 3 req/s)
 * - Metadata filtering: Composite userId + documentId filters supported
 *
 * Error Handling:
 * - Index connection errors are logged (graceful degradation)
 * - Services must check that index is defined before using
 */
let indexInstance: any;

if (pineconeInstance) {
  try {
    indexInstance = pineconeInstance.index(PINECONE_INDEX);
  } catch (error) {
    console.error(
      "Failed to connect to Pinecone index:",
      error instanceof Error ? error.message : String(error)
    );
  }
}

export const index = indexInstance;

/**
 * Metadata limits and constraints (Pinecone free tier):
 * - Max metadata size: ~40KB per vector
 * - Max metadata fields: 10 fields per vector (currently using 5)
 * - Max vectors: 100,000 per index
 * - Max requests/second: 3 (free tier)
 *
 * Troubleshooting:
 * - If connection fails, verify API key is valid and not expired
 * - If vectors have wrong dimension, check embedding model (must be 768 dims)
 * - If rate limited (429), implement exponential backoff and batch operations
 */
