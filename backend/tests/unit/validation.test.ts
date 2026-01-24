import { describe, test, expect } from "@jest/globals";
import {
  validatePDFHeader,
  validatePDFContent,
  validateTextDocument,
} from "../../src/utils/validation";
import { AppError } from "../../src/types/api.types";

describe("PDF Validation Utilities", () => {
  describe("validatePDFHeader", () => {
    test("should return true for valid PDF header", () => {
      // Valid PDF header starts with %PDF-
      const validPDF = Buffer.from("%PDF-1.4\nrest of pdf content");

      expect(validatePDFHeader(validPDF)).toBe(true);
    });

    test("should return true for different PDF versions", () => {
      const pdf17 = Buffer.from("%PDF-1.7\ncontent");
      const pdf14 = Buffer.from("%PDF-1.4\ncontent");

      expect(validatePDFHeader(pdf17)).toBe(true);
      expect(validatePDFHeader(pdf14)).toBe(true);
    });

    test("should return false for invalid header", () => {
      const invalidPDF = Buffer.from("This is not a PDF file");

      expect(validatePDFHeader(invalidPDF)).toBe(false);
    });

    test("should return false for empty buffer", () => {
      const emptyBuffer = Buffer.from("");

      expect(validatePDFHeader(emptyBuffer)).toBe(false);
    });

    test("should return false for buffer shorter than 5 bytes", () => {
      const shortBuffer = Buffer.from("%PDF");

      expect(validatePDFHeader(shortBuffer)).toBe(false);
    });

    test("should return false for non-PDF file types", () => {
      const imageHeader = Buffer.from("\x89PNG\r\n\x1a\n");
      const docxHeader = Buffer.from("PK\x03\x04");

      expect(validatePDFHeader(imageHeader)).toBe(false);
      expect(validatePDFHeader(docxHeader)).toBe(false);
    });
  });

  describe("validatePDFContent", () => {
    test("should not throw for valid PDF", () => {
      const validPDF = Buffer.from("%PDF-1.4\n%valid content");

      expect(() => validatePDFContent(validPDF)).not.toThrow();
    });

    test("should throw AppError for missing PDF header", () => {
      const invalidPDF = Buffer.from("Not a PDF");

      expect(() => validatePDFContent(invalidPDF)).toThrow(AppError);
    });

    test("should throw with correct error code for invalid PDF", () => {
      const invalidPDF = Buffer.from("fake content");

      try {
        validatePDFContent(invalidPDF);
        throw new Error("Expected AppError to be thrown");
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("INVALID_PDF_FILE");
        expect((error as AppError).statusCode).toBe(400);
        expect((error as AppError).details.reason).toBe("Missing PDF header");
      }
    });

    test("should throw with descriptive message", () => {
      const corruptPDF = Buffer.from("corrupt");

      try {
        validatePDFContent(corruptPDF);
        throw new Error("Expected AppError to be thrown");
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).message).toBe(
          "The PDF file appears to be corrupted or invalid",
        );
      }
    });
  });

  describe("validateTextDocument", () => {
    test("should pass validation for valid title and content", () => {
      const validTitle = "Valid Document Title";
      const validContent =
        "This is a valid content with more than 10 characters.";

      expect(() => {
        validateTextDocument(validTitle, validContent);
      }).not.toThrow();
    });

    test("should throw INVALID_TITLE for empty title", () => {
      const emptyTitle = "";
      const validContent = "This is valid content.";

      expect(() => {
        validateTextDocument(emptyTitle, validContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(emptyTitle, validContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("INVALID_TITLE");
        expect((error as AppError).message).toBe("Title must not be empty");
      }
    });

    test("should throw INVALID_TITLE for whitespace-only title", () => {
      const whitespaceTitle = "   ";
      const validContent = "This is valid content.";

      expect(() => {
        validateTextDocument(whitespaceTitle, validContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(whitespaceTitle, validContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("INVALID_TITLE");
        expect((error as AppError).message).toBe("Title must not be empty");
      }
    });

    test("should throw INVALID_TITLE for title longer than 100 characters", () => {
      const longTitle = "a".repeat(101);
      const validContent = "This is valid content.";

      expect(() => {
        validateTextDocument(longTitle, validContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(longTitle, validContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("INVALID_TITLE");
        expect((error as AppError).message).toBe(
          "Title must be between 1 and 100 characters",
        );
      }
    });

    test("should throw TEXT_TOO_SHORT for content shorter than 10 characters", () => {
      const validTitle = "Valid Title";
      const shortContent = "Short";

      expect(() => {
        validateTextDocument(validTitle, shortContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(validTitle, shortContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("TEXT_TOO_SHORT");
        expect((error as AppError).message).toBe(
          "Text content must be at least 10 characters",
        );
      }
    });

    test("should throw TEXT_TOO_SHORT for whitespace-only content", () => {
      const validTitle = "Valid Title";
      const whitespaceContent = "     ";

      expect(() => {
        validateTextDocument(validTitle, whitespaceContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(validTitle, whitespaceContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("TEXT_TOO_SHORT");
        expect((error as AppError).message).toBe(
          "Text content must be at least 10 characters",
        );
      }
    });

    test("should throw TEXT_TOO_LONG for content longer than 50,000 characters", () => {
      const validTitle = "Valid Title";
      const longContent = "a".repeat(50001);

      expect(() => {
        validateTextDocument(validTitle, longContent);
      }).toThrow(AppError);

      try {
        validateTextDocument(validTitle, longContent);
      } catch (error) {
        expect(error).toBeInstanceOf(AppError);
        expect((error as AppError).code).toBe("TEXT_TOO_LONG");
        expect((error as AppError).message).toBe(
          "Text content exceeds maximum length of 50,000 characters",
        );
      }
    });

    test("should pass validation for title exactly 100 characters", () => {
      const exactTitle = "a".repeat(100);
      const validContent =
        "This is valid content with more than 10 characters.";

      expect(() => {
        validateTextDocument(exactTitle, validContent);
      }).not.toThrow();
    });

    test("should pass validation for content exactly 10 characters", () => {
      const validTitle = "Valid Title";
      const exactContent = "1234567890"; // Exactly 10 characters

      expect(() => {
        validateTextDocument(validTitle, exactContent);
      }).not.toThrow();
    });

    test("should pass validation for content exactly 50,000 characters", () => {
      const validTitle = "Valid Title";
      const exactContent = "a".repeat(50000);

      expect(() => {
        validateTextDocument(validTitle, exactContent);
      }).not.toThrow();
    });
  });
});
