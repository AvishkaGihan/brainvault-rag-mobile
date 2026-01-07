/**
 * Pinecone Vector Database Configuration
 * Initializes Pinecone client for vector storage and retrieval operations
 * Placeholder for Story 1.4: Configure Pinecone Vector Database
 */

import { Pinecone } from "@pinecone-database/pinecone";
import dotenv from "dotenv";
dotenv.config();

/**
 * Initialize Pinecone client
 * Creates a new Pinecone client instance with API key authentication
 */
export const pinecone = new Pinecone({
  apiKey: process.env.PINECONE_API_KEY!,
});

/**
 * Default Pinecone index instance
 * Configured for BrainVault vector storage operations
 */
export const index = pinecone.index(process.env.PINECONE_INDEX!);
