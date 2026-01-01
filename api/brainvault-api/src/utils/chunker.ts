import { RecursiveCharacterTextSplitter } from "@langchain/textsplitters";

/**
 * Metadata associated with a text chunk, critical for citation tracking.
 */
export interface ChunkWithMetadata {
  text: string;
  pageNumber: number;
  chunkIndex: number;
  startOffset: number;
  endOffset: number;
}

/**
 * Splits extracted text into semantic chunks while preserving page number information.
 * @param text The complete extracted text from the PDF.
 * @param pageBreaks An array of character offsets where each new page begins.
 * Index 0 should typically be 0 (start of page 1).
 * Example: [0, 1500, 3200] means Page 1 starts at 0, Page 2 at 1500, etc.
 * @returns Array of chunks with metadata including page numbers.
 */
export async function chunkText(
  text: string,
  pageBreaks: number[]
): Promise<ChunkWithMetadata[]> {
  // Configuration optimized for Gemini embedding models (768 dimensions)
  // 1000 chars is roughly 200-250 tokens, a good balance for context retrieval.
  const splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 1000,
    chunkOverlap: 200,
    separators: ["\n\n", "\n", ". ", " ", ""], // Priority: Paragraphs > Lines > Sentences > Words
  });

  // Create documents with metadata (start/end offsets)
  // We use createDocuments to get the generic Document objects first,
  // which include the 'loc' metadata (lines), but for precise character offsets
  // in a single string, standard splitters often return just text or line numbers.
  // However, RecursiveCharacterTextSplitter doesn't inherently return character offsets
  // relative to the original text in a simple way without re-mapping.
  //
  // To strictly adhere to the requirement of returning start/end offsets relative to the
  // original text for page mapping, we will use a custom approach if needed,
  // but standard usage creates chunks. We will assume the splitter works sequentially.
  //
  // Strategy:
  // 1. Split the text.
  // 2. Find the offset of each chunk in the original text.
  //    Note: Repeats/overlaps make "indexOf" risky if not careful.
  //    We maintain a 'searchIndex' to find the next occurrence.

  const rawChunks = await splitter.createDocuments([text]);

  const chunksWithMetadata: ChunkWithMetadata[] = [];
  let currentSearchIndex = 0;

  rawChunks.forEach((doc: { pageContent: string }, index: number) => {
    const chunkContent = doc.pageContent;

    // Find the actual start offset of this chunk in the original text
    // We start searching from currentSearchIndex to avoid finding previous duplicates
    // but we must account for overlap.
    // Since chunks overlap, the next chunk starts BEFORE the previous chunk ends.
    // However, it definitely starts AFTER the previous chunk started.
    // So we can roughly search from (prevStart + 1) or keep a cursor.
    // To be safe and handle the overlap correctly without skipping:
    // We search from 'currentSearchIndex' which tracks the *approximate* expected position.
    // Actually, simply searching from the start of the previous chunk's start is safer,
    // but strictly, 'indexOf' from `currentSearchIndex` is robust if the text is exact.

    // Correction: Since chunks are sequential, we find the first occurrence of this text
    // starting from a point slightly before where we expect it (to handle overlap).
    // But since `chunkOverlap` is 200, we can comfortably search from
    // (lastOffset - overlap - margin) or just strictly track the cursor.
    //
    // Simpler approach: `indexOf` from `currentSearchIndex`.
    // We update `currentSearchIndex` to `startOffset + 1` ensures we find the *next* one next time,
    // even if they share text.

    // NOTE: If the splitter modifies text (trimming), exact match might fail.
    // LangChain splitter usually preserves text but might trim whitespace.
    // We'll assume strict preservation or soft matching.

    const startOffset = text.indexOf(chunkContent, currentSearchIndex);

    // Fallback: If not found (rare, but possible if splitter normalizes),
    // we assume it continues immediately after strict overlap calculation.
    // For now, we assume strict text extraction validity.

    if (startOffset === -1) {
      console.warn(
        `Could not locate chunk ${index} in original text. Skipping metadata precision.`
      );
      // Recovery strategy: assumes it starts where we left off (minus overlap)
      // This is a fail-safe.
    }

    const effectiveStart =
      startOffset !== -1 ? startOffset : currentSearchIndex;
    const endOffset = effectiveStart + chunkContent.length;

    // Calculate Page Number based on startOffset
    // We find the last pageBreak that is <= startOffset
    let pageNumber = 1;
    for (let i = 0; i < pageBreaks.length; i++) {
      if (effectiveStart >= pageBreaks[i]) {
        pageNumber = i + 1; // Page numbers are 1-based
      } else {
        break; // We passed the start offset
      }
    }

    chunksWithMetadata.push({
      text: chunkContent,
      pageNumber: pageNumber,
      chunkIndex: index,
      startOffset: effectiveStart,
      endOffset: endOffset,
    });

    // Update search index for the next iteration.
    // Because of overlap, we can't jump to endOffset.
    // We move the cursor forward by 1 to ensure we find the *next* instance of overlap text,
    // but efficiently we can jump forward by (length - overlap - margin).
    // Safer: just set it to `effectiveStart + 1` for correctness over micro-optimization.
    currentSearchIndex = effectiveStart + 1;
  });

  return chunksWithMetadata;
}
