/**
 * Chat Query Types
 * Story 5.4: RAG Query API endpoint types
 */

export interface ChatQueryRequest {
  question: string;
}

export interface ChatSource {
  pageNumber: number;
  snippet: string;
}

export interface ChatQueryResponseData {
  answer: string;
  sources: ChatSource[];
  confidence: number;
}
