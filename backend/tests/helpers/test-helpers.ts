/**
 * Test Helpers for Integration Tests
 * Provides utilities for mocking Firebase and generating test data
 */

import { jest } from "@jest/globals";
import admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";

// Mock Firebase modules before any imports
jest.mock("firebase-admin", () => ({
  initializeApp: jest.fn(),
  firestore: jest.fn(),
  storage: jest.fn(),
  auth: jest.fn(),
}));

jest.mock("firebase-admin/firestore", () => ({
  getFirestore: jest.fn(),
  Timestamp: {
    now: jest.fn().mockReturnValue({
      toDate: jest.fn().mockReturnValue(new Date()),
      toMillis: jest.fn().mockReturnValue(Date.now()),
    }),
  },
  FieldValue: {
    serverTimestamp: jest.fn().mockReturnValue({
      _type: "serverTimestamp",
      // This will be converted to Timestamp when retrieved
    }),
  },
}));

/**
 * Setup Firebase mocks for testing
 * Prevents actual Firebase calls during tests
 */
export function setupFirebaseMocks() {
  // Store for mock data to make it dynamic
  const storedData: { [key: string]: any } = {};
  let docIdCounter = 0;

  // Mock Firestore
  const mockDocRef = {
    id: "mock-doc-id",
    set: jest.fn<(data: any) => Promise<void>>().mockImplementation(function (
      this: any,
      data: any,
    ) {
      // Generate unique ID for this document
      const docId = `mock-doc-id-${++docIdCounter}`;
      this.id = docId;
      // Store the data that was set
      storedData[docId] = { ...data, id: docId };
      return Promise.resolve(undefined);
    }),
    get: jest.fn<() => Promise<any>>().mockImplementation(function (this: any) {
      const stored = storedData[this.id];
      if (stored) {
        // Convert FieldValue.serverTimestamp() to Timestamp objects
        const data = { ...stored };
        if (data.createdAt && data.createdAt._type === "serverTimestamp") {
          data.createdAt = Timestamp.now();
        }
        if (data.updatedAt && data.updatedAt._type === "serverTimestamp") {
          data.updatedAt = Timestamp.now();
        }
        return Promise.resolve({
          data: () => data,
        });
      }
      return Promise.resolve({
        data: () => ({
          id: this.id,
          userId: "testuser123",
          title: "test.pdf",
          status: "processing",
          fileName: "test.pdf",
          fileSize: 1024,
          pageCount: 0,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        }),
      });
    }),
    delete: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
  };

  const mockCollection = {
    doc: jest.fn<() => any>().mockReturnValue(mockDocRef),
  };

  const mockFirestore = {
    collection: jest.fn<() => any>().mockReturnValue(mockCollection),
  };

  // Mock Storage
  const mockFile = {
    save: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
    delete: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
  };

  const mockBucket = {
    file: jest.fn<() => any>().mockReturnValue(mockFile),
  };

  const mockStorage = {
    bucket: jest.fn<() => any>().mockReturnValue(mockBucket),
  };

  // Mock Auth
  const mockAuth = {
    verifyIdToken: jest.fn<() => Promise<any>>().mockResolvedValue({
      uid: "testuser123",
      email: "test@example.com",
    }),
  };

  // Apply mocks
  const { getFirestore } = require("firebase-admin/firestore");
  getFirestore.mockReturnValue(mockFirestore);

  return { mockDocRef, mockCollection, mockFirestore };
}

/**
 * Generate test authentication token
 * Returns a mock token for testing authenticated endpoints
 */
export function generateTestToken(uid: string = "testuser123"): string {
  return `mock-firebase-token-${uid}`;
}

/**
 * Create mock user object for authenticated requests
 */
export function createMockUser(
  uid: string = "testuser123",
  email: string = "test@example.com",
) {
  return { uid, email };
}
