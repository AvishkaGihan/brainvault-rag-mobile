import { ScoredPineconeRecord } from "@pinecone-database/pinecone";
import { Citation } from "../types/chat.types";

/**
 * Extracts and formats source citations from Pinecone vector search results.
 * Handles deduplication of page numbers and sorting by relevance.
 * @param queryResults - Raw matches returned from Pinecone query
 * @param documentName - Display name of the document being queried
 * @returns Array of unique, sorted citations
 */
export function extractCitations(
  queryResults: ScoredPineconeRecord<Record<string, any>>[],
  documentName: string
): Citation[] {
  if (!queryResults || queryResults.length === 0) {
    return [];
  }

  // 1. Map results to Citation objects
  const rawCitations: Citation[] = queryResults
    .filter(
      (match) => match.metadata && typeof match.metadata.pageNumber === "number"
    )
    .map((match) => {
      const metadata = match.metadata as any;
      return {
        documentId: metadata.documentId || "", // metadata should always have this based on ingestion
        documentName: documentName,
        pageNumber: Number(metadata.pageNumber),
        chunkText: metadata.text as string | undefined, // Optional snippet
        relevanceScore: match.score || 0,
      };
    });

  // 2. Deduplicate by page number
  // If multiple chunks point to the same page, keep the one with the highest relevance score
  const uniquePages = new Map<number, Citation>();

  rawCitations.forEach((citation) => {
    const existing = uniquePages.get(citation.pageNumber);
    if (
      !existing ||
      (citation.relevanceScore || 0) > (existing.relevanceScore || 0)
    ) {
      uniquePages.set(citation.pageNumber, citation);
    }
  });

  // 3. Convert back to array and sort by relevance (descending)
  return Array.from(uniquePages.values())
    .sort((a, b) => (b.relevanceScore || 0) - (a.relevanceScore || 0))
    .slice(0, 5); // Limit to top 5 distinct page citations to avoid clutter
}

/**
 * Helper to format a citation for UI display strings if needed backend-side.
 * e.g., "Contract.pdf (Page 5)"
 */
export function formatCitationText(citation: Citation): string {
  return `${citation.documentName} (Page ${citation.pageNumber})`;
}
