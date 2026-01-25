/**
 * Embedding Service Types
 * Story 3.6: Embedding Generation Service
 */

export interface ChunkMeta {
  pageNumber: number;
  chunkIndex: number;
  textPreview: string;
}

export interface EmbeddingInputChunk {
  text: string;
  metadata: ChunkMeta;
}

export interface EmbeddingResult {
  vector: number[];
  metadata: ChunkMeta;
}
