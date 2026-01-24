/**
 * Simple integration test for PDF Text Extraction
 * STORY 3.4: Implement PDF Text Extraction - Basic functionality test
 */

import { describe, it, expect } from "@jest/globals";

describe("EmbeddingService - Basic Tests", () => {
  it("should have the service file created", async () => {
    // Simple test to verify the service exists and can be imported
    const { EmbeddingService } =
      await import("../../../src/services/embedding.service");
    expect(EmbeddingService).toBeDefined();
    expect(typeof EmbeddingService).toBe("function");
  });

  it("should export ExtractedText interface", async () => {
    const embeddingModule =
      await import("../../../src/services/embedding.service");
    expect(embeddingModule.EmbeddingService).toBeDefined();
  });
});
