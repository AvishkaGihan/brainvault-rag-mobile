/**
 * Chat Routes Integration Tests
 * Story 5.4: RAG Query endpoint
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
import express, { type Express } from "express";
import { AppError } from "../../src/types";
import type { ChatQueryResponseData } from "../../src/types/chat.types";
import {
  setupFirebaseMocks,
  generateTestToken,
  createMockUser,
} from "../helpers/test-helpers";

type QueryDocument = (params: {
  userId: string;
  documentId: string;
  question: string;
}) => Promise<ChatQueryResponseData>;

const queryDocumentMock = jest.fn() as jest.MockedFunction<QueryDocument>;

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

jest.mock("../../src/services/rag-query.service", () => ({
  RagQueryService: jest.fn().mockImplementation(() => ({
    queryDocument: queryDocumentMock,
  })),
}));

// Setup Firebase mocks
setupFirebaseMocks();

import { router } from "../../src/routes";
import { errorHandler } from "../../src/middleware/error.middleware";

function createTestApp(): Express {
  const app = express();
  app.use(express.json());

  app.use((req: any, _res, next) => {
    if (req.headers.authorization) {
      req.user = createMockUser();
    }
    next();
  });

  app.use("/api", router);
  app.use(errorHandler);
  return app;
}

describe("Chat Routes Integration", () => {
  let app: Express;
  let authToken: string;

  beforeAll(() => {
    app = createTestApp();
    authToken = generateTestToken("testuser123");
  });

  beforeEach(() => {
    queryDocumentMock.mockReset();
  });

  it("should return success response on happy path", async () => {
    queryDocumentMock.mockResolvedValue({
      answer: "Test answer",
      sources: [{ pageNumber: 2, snippet: "Snippet" }],
      confidence: 0.92,
    });

    const response = await request(app)
      .post("/api/v1/documents/doc-1/chat")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ question: "What is this?" })
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty("answer");
    expect(response.body.data).toHaveProperty("sources");
    expect(response.body.data).toHaveProperty("confidence");
  });

  it("should return 400 for missing question", async () => {
    const response = await request(app)
      .post("/api/v1/documents/doc-1/chat")
      .set("Authorization", `Bearer ${authToken}`)
      .send({})
      .expect(400);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe("VALIDATION_ERROR");
    expect(queryDocumentMock).not.toHaveBeenCalled();
  });

  it("should return 400 for whitespace-only question", async () => {
    const response = await request(app)
      .post("/api/v1/documents/doc-1/chat")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ question: "   " })
      .expect(400);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe("VALIDATION_ERROR");
    expect(queryDocumentMock).not.toHaveBeenCalled();
  });

  it("should return fallback when no relevant chunks", async () => {
    queryDocumentMock.mockResolvedValue({
      answer: "I don't have information about that in your document.",
      sources: [],
      confidence: 0,
    });

    const response = await request(app)
      .post("/api/v1/documents/doc-1/chat")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ question: "Unknown question" })
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.data.answer).toBe(
      "I don't have information about that in your document.",
    );
    expect(response.body.data.sources).toEqual([]);
    expect(response.body.data.confidence).toBe(0);
  });

  it("should return safe error on ownership violation", async () => {
    queryDocumentMock.mockRejectedValue(
      new AppError(
        "UNAUTHORIZED",
        "You do not have permission to access this document",
        403,
      ),
    );

    const response = await request(app)
      .post("/api/v1/documents/doc-2/chat")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ question: "Test" })
      .expect(403);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe("UNAUTHORIZED");
  });
});
