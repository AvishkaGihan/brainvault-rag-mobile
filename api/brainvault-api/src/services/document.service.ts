import { Document } from "../types/document.types";

// Stub implementation for document service
export class DocumentService {
  async listDocuments(userId: string): Promise<Document[]> {
    // Stub: return empty array
    return [];
  }

  async deleteDocument(id: string, userId: string): Promise<void> {
    // Stub: do nothing
  }
}

export const documentService = new DocumentService();
