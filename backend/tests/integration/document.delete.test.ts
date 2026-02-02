/**
 * Document Delete Integration Tests
 * Story 4.5: Document Deletion
 * AC8-AC12: Test document deletion endpoints with ownership validation and cleanup
 */

import {
  describe,
  it,
  expect,
  beforeAll,
  beforeEach,
  jest,
} from "@jest/globals";
import request from "supertest";
import express, { Express } from "express";
import {
  setupFirebaseMocks,
  generateTestToken,
  createMockUser,
} from "../helpers/test-helpers";

// Mock Firebase before importing any modules that use it
jest.mock("../../src/config/firebase", () => ({
  auth: {
    verifyIdToken: jest.fn((token: string) => {
      if (token && token.startsWith("mock-firebase-token-")) {
        return Promise.resolve({
          uid: "testuser123",
          email: "test@example.com",
        });
      }
      throw new Error("Invalid token");
    }),
  },
}));

// Mock storage functions
jest.mock("../../src/config/storage", () => ({
  generateStoragePath: jest.fn(
    () => "users/testuser123/documents/mock-doc-id.pdf",
  ),
  uploadToStorage: jest.fn(() => Promise.resolve()),
  deleteFromStorage: jest.fn(() => Promise.resolve()),
}));

// Setup Firebase mocks
const firebaseMocks = setupFirebaseMocks();

import { router } from "../../src/routes";
import { errorHandler } from "../../src/middleware/error.middleware";

/**
 * Create test app with document routes
 */
function createTestApp(): Express {
  const app = express();
  app.use(express.json());

  // Mock auth middleware to bypass Firebase auth in tests
  app.use((req: any, res, next) => {
    if (req.headers.authorization) {
      req.user = createMockUser();
    }
    next();
  });

  app.use("/api", router);
  app.use(errorHandler);
  return app;
}

describe("Document Delete Routes Integration", () => {
  let app: Express;
  let authToken: string;

  beforeAll(() => {
    app = createTestApp();
    authToken = generateTestToken("testuser123");
  });

  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
  });

  describe("DELETE /api/v1/documents/:documentId", () => {
    it("should delete document successfully (AC8, AC9)", async () => {
      const documentId = "test-doc-123";

      // Setup mock: document exists and belongs to user
      firebaseMocks.mockDocRef.get.mockResolvedValueOnce({
        exists: true,
        id: documentId,
        data: () => ({
          id: documentId,
          userId: "testuser123",
          title: "Test Document",
          status: "ready",
          storagePath: "users/testuser123/documents/test-doc-123.pdf",
        }),
      });

      // Setup mock: batch delete for document + chats
      const mockBatch: any = {
        delete: jest.fn(),
        commit: jest.fn(() => Promise.resolve()),
      };
      (firebaseMocks.mockFirestore as any).batch.mockReturnValue(mockBatch);

      // Mock deleteFromStorage to succeed
      const { deleteFromStorage } = require("../../src/config/storage");
      deleteFromStorage.mockResolvedValueOnce(undefined);

      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("message");
      expect(mockBatch.commit).toHaveBeenCalled();
    });

    it("should return 404 when document not found (AC10)", async () => {
      const documentId = "nonexistent-doc";

      // Setup mock: document does not exist
      firebaseMocks.mockDocRef.get.mockResolvedValueOnce({
        exists: false,
      });

      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe("DOCUMENT_NOT_FOUND");
    });

    it("should return 403 when user does not own document (AC8)", async () => {
      const documentId = "test-doc-123";

      // Setup mock: document exists but owned by different user
      firebaseMocks.mockDocRef.get.mockResolvedValueOnce({
        exists: true,
        id: documentId,
        data: () => ({
          id: documentId,
          userId: "differentuser456", // Different user
          title: "Test Document",
          status: "ready",
        }),
      });

      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe("UNAUTHORIZED");
    });

    it("should return 401 when no auth token provided (AC8)", async () => {
      const documentId = "test-doc-123";

      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe("UNAUTHORIZED");
    });

    it("should delete document in processing status (AC6)", async () => {
      const documentId = "processing-doc-123";

      // Setup mock: document exists with processing status
      firebaseMocks.mockDocRef.get.mockResolvedValueOnce({
        exists: true,
        id: documentId,
        data: () => ({
          id: documentId,
          userId: "testuser123",
          title: "Processing Document",
          status: "processing",
          storagePath: "users/testuser123/documents/processing-doc-123.pdf",
        }),
      });

      // Setup batch delete
      const mockBatch: any = {
        delete: jest.fn(),
        commit: jest.fn(() => Promise.resolve()),
      };
      (firebaseMocks.mockFirestore as any).batch.mockReturnValue(mockBatch);

      const { deleteFromStorage } = require("../../src/config/storage");
      deleteFromStorage.mockResolvedValueOnce(undefined);

      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it("should handle Storage deletion error gracefully", async () => {
      const documentId = "test-doc-123";

      firebaseMocks.mockDocRef.get.mockResolvedValueOnce({
        exists: true,
        id: documentId,
        data: () => ({
          id: documentId,
          userId: "testuser123",
          title: "Test Document",
          status: "ready",
          storagePath: "users/testuser123/documents/test-doc-123.pdf",
        }),
      });

      // Setup batch delete to succeed
      const mockBatch: any = {
        delete: jest.fn(),
        commit: jest.fn(() => Promise.resolve()),
      };
      (firebaseMocks.mockFirestore as any).batch.mockReturnValue(mockBatch);

      // Setup Storage to fail
      const { deleteFromStorage } = require("../../src/config/storage");
      deleteFromStorage.mockRejectedValueOnce(new Error("Storage error"));

      // Should still succeed (Storage deletion is best-effort)
      const response = await request(app)
        .delete(`/api/v1/documents/${documentId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });
});
