/**
 * Chat Query Types
 * Story 5.4: RAG Query API endpoint types
 */

import { FieldValue, Timestamp } from "firebase-admin/firestore";

export interface ChatQueryRequest {
  question: string;
}

export interface ChatSource {
  pageNumber: number;
  snippet: string;
}

export type ChatMessageRole = "user" | "assistant";

export interface ChatMessageRecord {
  role: ChatMessageRole;
  content: string;
  sources: ChatSource[];
  timestamp: Timestamp | FieldValue;
}

export interface ChatHistoryMessage {
  role: ChatMessageRole;
  content: string;
  sources: ChatSource[];
  timestamp: string;
}

export interface ChatHistory {
  chatId: string;
  messages: ChatHistoryMessage[];
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
