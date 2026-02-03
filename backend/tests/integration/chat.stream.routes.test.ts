/**
 * Chat Streaming Routes Integration Tests
 * Story 5.6: SSE streaming endpoint
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
import type { ChatStreamDonePayload } from "../../src/types/chat.types";
import {
  setupFirebaseMocks,
  generateTestToken,
  createMockUser,
} from "../helpers/test-helpers";

type StreamDocument = (params: {
  userId: string;
  documentId: string;
  question: string;
}) => Promise<{
  stream: AsyncIterable<string> | null;
  done: ChatStreamDonePayload;
}>;

const streamDocumentMock = jest.fn() as jest.MockedFunction<StreamDocument>;

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

jest.mock("../../src/services/rag-query-stream.service", () => ({
  RagQueryStreamService: jest.fn().mockImplementation(() => ({
    streamDocument: streamDocumentMock,
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

async function* createDeltaStream() {
  yield "Hello ";
  yield "world";
}

describe("Chat Stream Routes Integration", () => {
  let app: Express;
  let authToken: string;

  beforeAll(() => {
    app = createTestApp();
    authToken = generateTestToken("testuser123");
  });

  beforeEach(() => {
    streamDocumentMock.mockReset();
  });

  it("should return SSE content type and stream events", async () => {
    const donePayload: ChatStreamDonePayload = {
      answer: "Hello world",
      sources: [{ pageNumber: 1, snippet: "Snippet" }],
      confidence: 0.92,
    };

    streamDocumentMock.mockResolvedValue({
      stream: createDeltaStream(),
      done: donePayload,
    });

    const response = await request(app)
      .post("/api/v1/documents/doc-1/chat/stream")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ question: "What is this?" })
      .expect(200);

    expect(response.header["content-type"]).toContain("text/event-stream");

    const frames = response.text.split("\n\n").filter(Boolean);
    const events = frames.map((frame) => {
      const lines = frame.split("\n");
      const eventLine = lines.find((line) => line.startsWith("event:"));
      const dataLine = lines.find((line) => line.startsWith("data:"));
      return {
        event: eventLine?.replace("event:", "").trim(),
        data: dataLine?.replace("data:", "").trim(),
      };
    });

    const hasDelta = events.some((event) => event.event === "delta");
    const doneEvent = events.find((event) => event.event === "done");

    expect(hasDelta).toBe(true);
    expect(doneEvent).toBeDefined();

    const doneData = doneEvent?.data ? JSON.parse(doneEvent.data) : null;
    expect(doneData).toHaveProperty("sources");
    expect(Array.isArray(doneData.sources)).toBe(true);
  });
});
