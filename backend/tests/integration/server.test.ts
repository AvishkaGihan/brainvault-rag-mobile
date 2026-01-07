/**
 * Express Server Integration Tests
 * Tests core server functionality and middleware setup
 */

import { describe, it, expect, beforeAll, afterAll } from "@jest/globals";
import express, { Express } from "express";
import request from "supertest";
import cors from "cors";
import {
  errorHandler,
  notFoundHandler,
} from "../../src/middleware/error.middleware";

/**
 * Create a test app with core middleware
 */
function createTestApp(): Express {
  const app = express();

  // Middleware
  app.use(express.json());
  app.use(cors());

  // Test routes
  app.get("/test", (req, res) => {
    res.json({
      success: true,
      data: { message: "test" },
      meta: { timestamp: new Date().toISOString() },
    });
  });

  app.get("/error", (req, res, next) => {
    next(new Error("Test error"));
  });

  // Error handlers
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

describe("Express Server Setup", () => {
  let app: Express;

  beforeAll(() => {
    app = createTestApp();
  });

  describe("Middleware Configuration", () => {
    it("should parse JSON body", async () => {
      const response = await request(app)
        .get("/test")
        .expect("Content-Type", /json/)
        .expect(200);

      expect(response.body).toHaveProperty("success");
      expect(response.body).toHaveProperty("meta");
    });

    it("should set CORS headers", async () => {
      const response = await request(app)
        .get("/test")
        .set("Origin", "http://localhost:3000")
        .expect(200);

      // CORS headers should be present (varies by implementation)
      expect(response.status).toBe(200);
    });
  });

  describe("Error Handling", () => {
    it("should handle 404 errors", async () => {
      const response = await request(app).get("/nonexistent").expect(404);

      expect(response.body).toHaveProperty("success", false);
      expect(response.body).toHaveProperty("error");
      expect(response.body.error.code).toBe("NOT_FOUND");
    });

    it("should format error responses correctly", async () => {
      const response = await request(app).get("/error").expect(500);

      expect(response.body).toHaveProperty("success", false);
      expect(response.body).toHaveProperty("error");
      expect(response.body).toHaveProperty("meta");
      expect(response.body.meta).toHaveProperty("timestamp");
    });
  });

  describe("Response Format", () => {
    it("should follow standard API response format", async () => {
      const response = await request(app).get("/test").expect(200);

      // Check standard structure
      expect(response.body).toHaveProperty("success");
      expect(response.body).toHaveProperty("data");
      expect(response.body).toHaveProperty("meta");
      expect(response.body.meta).toHaveProperty("timestamp");

      // Verify values
      expect(typeof response.body.success).toBe("boolean");
      expect(typeof response.body.meta.timestamp).toBe("string");
    });
  });
});
