/**
 * Auth Middleware Tests
 * Story 2.7: Implement Backend Auth Middleware
 *
 * Tests verify:
 * AC1: Valid token authentication and req.user population
 * AC2: Missing token rejection (401)
 * AC3: Invalid/expired token rejection (401)
 * AC4: Health check exemption (tested in integration)
 * AC7: User isolation with req.user.uid
 *
 * Test Strategy: Red-Green-Refactor
 * - Red: Write failing tests first
 * - Green: Implement minimal code to pass
 * - Refactor: Improve structure while keeping tests green
 */

import { describe, it, expect, jest, beforeEach } from "@jest/globals";
import { Request, Response, NextFunction } from "express";
import { verifyAuth } from "../../../src/middleware/auth.middleware";
import { auth } from "../../../src/config/firebase";
import { AppError } from "../../../src/middleware/error.middleware";

type MockRequest = Request & {
  user?: {
    uid: string;
    email?: string;
  };
};

// Mock Firebase Admin SDK
jest.mock("../../../src/config/firebase", () => ({
  auth: {
    verifyIdToken: jest.fn() as jest.MockedFunction<
      (token: string) => Promise<{
        uid: string;
        email?: string;
        iat: number;
        exp: number;
      }>
    >,
  },
}));

/**
 * Mock Express objects for testing
 */
const createMockRequest = (authHeader?: string): Partial<MockRequest> => ({
  headers: authHeader ? { authorization: authHeader } : {},
  user: undefined,
});

const createMockResponse = (): Partial<Response> => {
  const res: Partial<Response> = {};
  res.status = jest.fn().mockReturnValue(res) as unknown as (
    code: number,
  ) => Response;
  res.json = jest.fn().mockReturnValue(res) as unknown as Response["json"];
  return res;
};

const createMockNext = (): NextFunction => jest.fn() as unknown as NextFunction;

/**
 * Test fixtures
 */
const VALID_TOKEN = "valid-firebase-jwt-token";
const INVALID_TOKEN = "invalid-token";
const EXPIRED_TOKEN = "expired-token";

const MOCK_DECODED_TOKEN = {
  uid: "test-user-123",
  email: "test@example.com",
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + 3600,
};

describe("Auth Middleware - verifyAuth", () => {
  beforeEach(() => {
    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  /**
   * AC1: Valid Token Authentication
   * Given: Valid Firebase JWT token in Authorization header
   * Then: req.user is populated with uid and email
   * And: next() is called to proceed
   */
  describe("AC1: Valid Token Authentication", () => {
    it("should populate req.user with uid and email for valid token", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${VALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Mock successful token verification
      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue(MOCK_DECODED_TOKEN as any);

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(auth.verifyIdToken).toHaveBeenCalledWith(VALID_TOKEN);
      expect(req.user).toEqual({
        uid: MOCK_DECODED_TOKEN.uid,
        email: MOCK_DECODED_TOKEN.email,
      });
      expect(next).toHaveBeenCalledWith(); // No error passed
      expect(res.status).not.toHaveBeenCalled(); // No response sent
    });

    it("should handle token without email field", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${VALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      const decodedTokenNoEmail = {
        uid: "test-user-456",
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 3600,
      };

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue(decodedTokenNoEmail as any);

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(req.user).toEqual({
        uid: decodedTokenNoEmail.uid,
        email: undefined,
      });
      expect(next).toHaveBeenCalledWith();
    });

    it("should extract token correctly from Bearer format", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${VALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue(MOCK_DECODED_TOKEN as any);

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(auth.verifyIdToken).toHaveBeenCalledWith(VALID_TOKEN);
      expect(next).toHaveBeenCalledWith();
    });
  });

  /**
   * AC2: Missing Token Rejection
   * Given: No Authorization header
   * Then: 401 error thrown with "No authentication token provided"
   */
  describe("AC2: Missing Token Rejection", () => {
    it("should throw 401 when Authorization header is missing", async () => {
      // Arrange
      const req = createMockRequest() as MockRequest; // No auth header
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          code: "UNAUTHORIZED",
          message: "No authentication token provided",
        }),
      );
      expect(auth.verifyIdToken).not.toHaveBeenCalled();
    });

    it("should throw 401 when Authorization header does not start with Bearer", async () => {
      // Arrange
      const req = createMockRequest("Basic some-token") as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          code: "UNAUTHORIZED",
          message: "No authentication token provided",
        }),
      );
      expect(auth.verifyIdToken).not.toHaveBeenCalled();
    });

    it("should throw 401 when Bearer format is malformed (no token)", async () => {
      // Arrange
      const req = createMockRequest("Bearer ") as MockRequest; // Empty token
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          code: "UNAUTHORIZED",
          message: "No authentication token provided",
        }),
      );
      expect(auth.verifyIdToken).not.toHaveBeenCalled();
    });
  });

  /**
   * AC3: Invalid Token Rejection
   * Given: Invalid or expired Firebase JWT token
   * Then: 401 error thrown with "Invalid or expired authentication token"
   */
  describe("AC3: Invalid Token Rejection", () => {
    it("should throw 401 when token verification fails", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${INVALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Mock token verification failure
      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockRejectedValue(new Error("Token verification failed"));

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(auth.verifyIdToken).toHaveBeenCalledWith(INVALID_TOKEN);
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          code: "UNAUTHORIZED",
          message: "Invalid or expired authentication token",
        }),
      );
      expect(req.user).toBeUndefined();
    });

    it("should throw 401 when token is expired", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${EXPIRED_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      // Mock Firebase expiry error
      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockRejectedValue(new Error("Firebase ID token has expired"));

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          code: "UNAUTHORIZED",
          message: "Invalid or expired authentication token",
        }),
      );
    });

    it("should throw 401 when token signature is invalid", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${INVALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockRejectedValue(new Error("Invalid token signature"));

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(next).toHaveBeenCalledWith(
        expect.objectContaining({
          statusCode: 401,
          message: "Invalid or expired authentication token",
        }),
      );
    });
  });

  /**
   * AC7: User Isolation
   * Given: Authenticated user with UID
   * Then: req.user.uid is set for data filtering
   */
  describe("AC7: User Isolation", () => {
    it("should set req.user.uid for subsequent middleware", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${VALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      const userUid = "user-abc-123";
      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue({
        uid: userUid,
        email: "user@example.com",
      } as any);

      // Act
      await verifyAuth(req, res, next);

      // Assert
      expect(req.user?.uid).toBe(userUid);
      expect(req.user?.email).toBe("user@example.com");
    });

    it("should allow different users to have different UIDs", async () => {
      // User 1
      const req1 = createMockRequest(`Bearer token1`) as MockRequest;
      const res1 = createMockResponse() as Response;
      const next1 = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue({
        uid: "user-1",
        email: "user1@example.com",
      } as any);

      await verifyAuth(req1, res1, next1);

      // User 2
      const req2 = createMockRequest(`Bearer token2`) as MockRequest;
      const res2 = createMockResponse() as Response;
      const next2 = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue({
        uid: "user-2",
        email: "user2@example.com",
      } as any);

      await verifyAuth(req2, res2, next2);

      // Assert: Each request has different user data
      expect(req1.user?.uid).toBe("user-1");
      expect(req2.user?.uid).toBe("user-2");
      expect(req1.user?.uid).not.toBe(req2.user?.uid);
    });
  });

  /**
   * Edge Cases & Error Handling
   */
  describe("Edge Cases", () => {
    it("should handle multiple Bearer keywords in header", async () => {
      // Arrange
      const req = createMockRequest(`Bearer Bearer ${VALID_TOKEN}`) as MockRequest;
      const res = createMockResponse() as Response;
      const next = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockResolvedValue(MOCK_DECODED_TOKEN as any);

      // Act
      await verifyAuth(req, res, next);

      // Assert - Should extract "Bearer <token>" after first "Bearer "
      expect(auth.verifyIdToken).toHaveBeenCalledWith(`Bearer ${VALID_TOKEN}`);
    });

    it("should not modify req.user if token verification fails", async () => {
      // Arrange
      const req = createMockRequest(`Bearer ${INVALID_TOKEN}`) as MockRequest;
      req.user = { uid: "previous-user", email: "old@example.com" };
      const res = createMockResponse() as Response;
      const next = createMockNext();

      (
        auth.verifyIdToken as jest.MockedFunction<typeof auth.verifyIdToken>
      ).mockRejectedValue(new Error("Invalid token"));

      // Act
      await verifyAuth(req, res, next);

      // Assert - req.user should remain unchanged
      expect(req.user).toEqual({
        uid: "previous-user",
        email: "old@example.com",
      });
    });
  });
});
