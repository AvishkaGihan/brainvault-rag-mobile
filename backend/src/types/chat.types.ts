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

export interface ChatStreamDeltaPayload {
  text: string;
}

export interface ChatStreamDonePayload {
  answer: string;
  sources: ChatSource[];
  confidence: number;
}

export interface ChatStreamErrorPayload {
  code: string;
  message: string;
}
