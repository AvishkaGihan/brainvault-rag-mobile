import { jest, describe, it, expect, beforeEach, test } from "@jest/globals";
import { DocumentService } from "../../src/services/document.service";
import { AppError } from "../../src/types/api.types";
import { getFirestore } from "firebase-admin/firestore";
import * as storage from "../../src/config/storage";

// Mock Firebase and storage
jest.mock("firebase-admin/firestore");
jest.mock("../../src/config/storage");
jest.mock("../../src/services/vector.service", () => ({
  VectorService: jest.fn().mockImplementation(() => ({
    deleteDocumentVectorsByIds: jest
      .fn<() => Promise<{ deletedCount: number }>>()
      .mockResolvedValue({ deletedCount: 0 }),
    upsertDocumentEmbeddings: jest.fn<() => Promise<{ vectorCount: number }>>(),
  })),
}));

// Mock validation module
jest.mock("../../src/utils/validation", () => ({
  validatePDFContent: jest.fn(),
  validateTextDocument: jest.fn((title: string, content: string) => {
    // Real validation logic for integration testing
    if (!title || title.length === 0) {
      throw new AppError("INVALID_TITLE", "Title must not be empty", 400, {
        titleLength: 0,
        minLength: 1,
      });
    }
    if (title.length > 100) {
      throw new AppError(
        "INVALID_TITLE",
        "Title must be between 1 and 100 characters",
        400,
        {
          titleLength: title.length,
          maxLength: 100,
        },
      );
    }
    if (!content || content.trim().length < 10) {
      throw new AppError(
        "TEXT_TOO_SHORT",
        "Text content must be at least 10 characters",
        400,
        {
          contentLength: content.trim().length,
          minLength: 10,
        },
      );
    }
    if (content.length > 50000) {
      throw new AppError(
        "TEXT_TOO_LONG",
        "Text content exceeds maximum length of 50,000 characters",
        400,
        {
          contentLength: content.length,
          maxLength: 50000,
        },
      );
    }
  }),
}));

// Import after mock setup
import * as validation from "../../src/utils/validation";

describe("DocumentService", () => {
  let service: DocumentService;
  let mockFirestore: any;
  let mockDocRef: any;
  let mockCollection: any;
  let mockChunksCollection: any;

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Setup Firestore mocks
    const mockChunkDocRef = {
      id: "0",
      delete: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
    };

    mockChunksCollection = {
      doc: jest
        .fn<(id?: string) => any>()
        .mockImplementation((id?: string) => ({
          ...mockChunkDocRef,
          id: id ?? mockChunkDocRef.id,
        })),
      get: jest.fn<() => Promise<any>>().mockResolvedValue({ docs: [] }),
    };

    mockDocRef = {
      id: "doc123",
      set: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
      get: jest.fn<() => Promise<any>>().mockResolvedValue({
        data: () => ({
          id: "doc123",
          userId: "user123",
          title: "test.pdf",
          status: "processing",
          createdAt: { toDate: () => new Date("2026-01-23T10:00:00Z") },
        }),
      }),
      delete: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
      update: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
      collection: jest.fn<() => any>().mockReturnValue(mockChunksCollection),
    };

    mockCollection = {
      doc: jest.fn<() => any>().mockReturnValue(mockDocRef),
    };

    mockFirestore = {
      collection: jest.fn<() => any>().mockReturnValue(mockCollection),
      batch: jest.fn<() => any>().mockImplementation(() => {
        const operations: any[] = [];
        return {
          delete: jest.fn((ref: any) => operations.push(ref)),
          commit: jest.fn<() => Promise<void>>().mockResolvedValue(undefined),
          _ops: operations,
        };
      }),
      runTransaction: jest
        .fn<(fn: (tx: any) => Promise<any>) => Promise<any>>()
        .mockImplementation(async (fn: (tx: any) => Promise<any>) => {
          const transaction = {
            get: jest.fn((ref: any) => ref.get()),
            update: jest.fn((ref: any, data: any) => ref.update(data)),
          };
          return fn(transaction);
        }),
    };

    (getFirestore as any).mockReturnValue(mockFirestore);

    service = new DocumentService();
  });

  describe("uploadPDFDocument", () => {
    const mockFile = {
      originalname: "test.pdf",
      mimetype: "application/pdf",
      size: 1024 * 1024, // 1MB
      buffer: Buffer.from("%PDF-1.4\nvalid pdf content"),
    } as Express.Multer.File;

    test("should upload valid PDF and create Firestore record", async () => {
      // Mock validation
      (validation.validatePDFContent as any).mockImplementation(() => {});

      // Mock storage
      (storage.generateStoragePath as any).mockReturnValue(
        "users/user123/documents/doc123.pdf",
      );
      (storage.uploadToStorage as any).mockResolvedValue(
        "users/user123/documents/doc123.pdf",
      );

      const result = await service.uploadPDFDocument("user123", mockFile);

      // Verify validation called
      expect(validation.validatePDFContent).toHaveBeenCalledWith(
        mockFile.buffer,
      );

      // Verify storage path generated
      expect(storage.generateStoragePath).toHaveBeenCalledWith(
        "user123",
        "doc123",
      );

      // Verify file uploaded
      expect(storage.uploadToStorage).toHaveBeenCalledWith(
        mockFile.buffer,
        "users/user123/documents/doc123.pdf",
        mockFile.mimetype,
      );

      // Verify Firestore document created
      expect(mockDocRef.set).toHaveBeenCalled();

      // Verify result
      expect(result.userId).toBe("user123");
      expect(result.status).toBe("processing");
    });

    test("should throw error for corrupt PDF (missing header)", async () => {
      const corruptFile = {
        ...mockFile,
        buffer: Buffer.from("This is not a PDF"),
      } as Express.Multer.File;

      // Mock validation to throw
      (validation.validatePDFContent as any).mockImplementation(() => {
        throw new AppError(
          "INVALID_PDF_FILE",
          "The PDF file appears to be corrupted or invalid",
          400,
          { reason: "Missing PDF header" },
        );
      });

      await expect(
        service.uploadPDFDocument("user123", corruptFile),
      ).rejects.toThrow(AppError);
    });

    test("should cleanup Storage file if Firestore write fails", async () => {
      // Mock validation
      (validation.validatePDFContent as any).mockImplementation(() => {});

      // Mock storage
      (storage.generateStoragePath as any).mockReturnValue(
        "users/user123/documents/doc123.pdf",
      );
      (storage.uploadToStorage as any).mockResolvedValue(
        "users/user123/documents/doc123.pdf",
      );
      (storage.deleteFromStorage as any).mockResolvedValue(undefined);

      // Mock Firestore to fail
      mockDocRef.set.mockRejectedValue(new Error("Firestore error"));

      await expect(
        service.uploadPDFDocument("user123", mockFile),
      ).rejects.toThrow(AppError);

      // Verify cleanup called
      expect(storage.deleteFromStorage).toHaveBeenCalledWith(
        "users/user123/documents/doc123.pdf",
      );
      expect(mockDocRef.delete).toHaveBeenCalled();
    });
  });

  describe("createTextDocument", () => {
    test("should create text document with valid input", async () => {
      const title = "My Notes";
      const content = "This is valid content with more than 10 characters";

      mockDocRef.get.mockResolvedValue({
        data: () => ({
          id: "doc456",
          userId: "user123",
          title,
          content,
          status: "processing",
          pageCount: 1,
          fileSize: content.length,
          createdAt: { toDate: () => new Date("2026-01-23T10:00:00Z") },
        }),
      });

      const result = await service.createTextDocument(
        "user123",
        title,
        content,
      );

      // Verify Firestore document created
      expect(mockDocRef.set).toHaveBeenCalled();
      const setCall = mockDocRef.set.mock.calls[0][0];
      expect(setCall.userId).toBe("user123");
      expect(setCall.title).toBe(title);
      expect(setCall.content).toBe(content);
      expect(setCall.pageCount).toBe(1);
      expect(setCall.fileSize).toBe(content.length);
      expect(setCall.status).toBe("processing");

      // Verify result
      expect(result.title).toBe(title);
      expect(result.status).toBe("processing");
      expect(result.pageCount).toBe(1);
    });

    test("should throw TEXT_TOO_SHORT for content < 10 chars", async () => {
      await expect(
        service.createTextDocument("user123", "Title", "Short"),
      ).rejects.toThrow(AppError);

      try {
        await service.createTextDocument("user123", "Title", "Short");
      } catch (error) {
        expect((error as AppError).code).toBe("TEXT_TOO_SHORT");
        expect((error as AppError).statusCode).toBe(400);
      }
    });

    test("should throw TEXT_TOO_LONG for content > 50k chars", async () => {
      const longContent = "a".repeat(50001);

      await expect(
        service.createTextDocument("user123", "Title", longContent),
      ).rejects.toThrow(AppError);

      try {
        await service.createTextDocument("user123", "Title", longContent);
      } catch (error) {
        expect((error as AppError).code).toBe("TEXT_TOO_LONG");
        expect((error as AppError).statusCode).toBe(400);
        expect((error as AppError).details.contentLength).toBe(50001);
      }
    });

    test("should throw INVALID_TITLE for empty title", async () => {
      await expect(
        service.createTextDocument("user123", "", "Valid content here"),
      ).rejects.toThrow(AppError);

      try {
        await service.createTextDocument("user123", "", "Valid content here");
      } catch (error) {
        expect((error as AppError).code).toBe("INVALID_TITLE");
        expect((error as AppError).statusCode).toBe(400);
      }
    });

    test("should throw INVALID_TITLE for title > 100 chars", async () => {
      const longTitle = "a".repeat(101);

      await expect(
        service.createTextDocument("user123", longTitle, "Valid content"),
      ).rejects.toThrow(AppError);

      try {
        await service.createTextDocument("user123", longTitle, "Valid content");
      } catch (error) {
        expect((error as AppError).code).toBe("INVALID_TITLE");
        expect((error as AppError).details.titleLength).toBe(101);
      }
    });

    test("should accept exactly 10 characters (boundary test)", async () => {
      const content = "1234567890"; // Exactly 10 characters

      mockDocRef.get.mockResolvedValue({
        data: () => ({
          id: "doc789",
          userId: "user123",
          title: "Test",
          content,
          status: "processing",
          createdAt: { toDate: () => new Date() },
        }),
      });

      await expect(
        service.createTextDocument("user123", "Test", content),
      ).resolves.toBeDefined();
    });

    test("should accept exactly 50000 characters (boundary test)", async () => {
      const content = "a".repeat(50000); // Exactly 50000 characters

      mockDocRef.get.mockResolvedValue({
        data: () => ({
          id: "doc790",
          userId: "user123",
          title: "Test",
          content,
          status: "processing",
          createdAt: { toDate: () => new Date() },
        }),
      });

      await expect(
        service.createTextDocument("user123", "Test", content),
      ).resolves.toBeDefined();
    });
  });

  describe("getDocumentStatus", () => {
    test("should return status for matching user", async () => {
      mockDocRef.get.mockResolvedValue({
        data: () => ({
          id: "doc123",
          userId: "user123",
          status: "processing",
          updatedAt: { toDate: () => new Date("2026-01-25T10:00:00Z") },
        }),
      });

      const result = await service.getDocumentStatus("user123", "doc123");

      expect(result.documentId).toBe("doc123");
      expect(result.status).toBe("processing");
      expect(result.updatedAt).toBe("2026-01-25T10:00:00.000Z");
      expect(result.errorMessage).toBeUndefined();
    });

    test("should throw DOCUMENT_NOT_FOUND when document missing", async () => {
      mockDocRef.get.mockResolvedValue({
        data: () => undefined,
      });

      await expect(
        service.getDocumentStatus("user123", "missing-doc"),
      ).rejects.toThrow(AppError);

      try {
        await service.getDocumentStatus("user123", "missing-doc");
      } catch (error) {
        expect((error as AppError).code).toBe("DOCUMENT_NOT_FOUND");
        expect((error as AppError).statusCode).toBe(404);
      }
    });

    test("should throw DOCUMENT_NOT_FOUND when user mismatch", async () => {
      mockDocRef.get.mockResolvedValue({
        data: () => ({
          id: "doc123",
          userId: "other-user",
          status: "ready",
          updatedAt: { toDate: () => new Date("2026-01-25T10:00:00Z") },
        }),
      });

      await expect(
        service.getDocumentStatus("user123", "doc123"),
      ).rejects.toThrow(AppError);

      try {
        await service.getDocumentStatus("user123", "doc123");
      } catch (error) {
        expect((error as AppError).code).toBe("DOCUMENT_NOT_FOUND");
      }
    });
  });

  describe("cancelDocument", () => {
    test("should delete chunks and document even if Pinecone deletion fails", async () => {
      mockDocRef.get.mockResolvedValue({
        exists: true,
        data: () => ({
          id: "doc123",
          userId: "user123",
          status: "processing",
          storagePath: "users/user123/documents/doc123.pdf",
        }),
      });

      mockChunksCollection.get.mockResolvedValue({
        docs: [{ id: "0" }, { id: "1" }],
      });

      const vectorServiceInstance = (
        service as unknown as {
          vectorService: {
            deleteDocumentVectorsByIds: jest.MockedFunction<
              () => Promise<{ deletedCount: number }>
            >;
          };
        }
      ).vectorService;

      vectorServiceInstance.deleteDocumentVectorsByIds.mockRejectedValue(
        new Error("Pinecone error"),
      );

      const result = await service.cancelDocument("user123", "doc123");

      expect(result.cancelled).toBe(true);
      expect(storage.deleteFromStorage).toHaveBeenCalledWith(
        "users/user123/documents/doc123.pdf",
      );
      expect(mockDocRef.delete).toHaveBeenCalled();
      expect(mockChunksCollection.doc).toHaveBeenCalledWith("0");
      expect(mockChunksCollection.doc).toHaveBeenCalledWith("1");
    });
  });

  describe("triggerTextExtraction", () => {
    test("should stop processing when document is missing", async () => {
      mockDocRef.get.mockResolvedValue({
        exists: false,
        data: () => undefined,
      });

      await (service as any).triggerTextExtraction("doc123");

      expect(mockDocRef.update).not.toHaveBeenCalled();
    });
  });
});
