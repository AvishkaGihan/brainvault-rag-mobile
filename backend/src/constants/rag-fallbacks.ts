/**
 * RAG fallback copy and guardrails
 * Story 5.7: Hallucination prevention
 */

/**
 * Patterns for detecting questions that are clearly outside document scope.
 * Uses stricter patterns to minimize false positives for legitimate document questions.
 * E.g., "When is..." matches time queries, but "when was it updated" should not match.
 */
const OUT_OF_SCOPE_PATTERNS: RegExp[] = [
  // Weather and forecast - must be about current weather, not document history
  /^what's?\s+(the\s+)?weather\b/i,
  /^(will\s+it\s+)?rain\b/i,
  /^(temperature|forecast|snow|wind)\b/i,
  // Time-based - current time/date/news only
  /^what('s|'s)?\s+(the\s+)?current\s+(time|date|news|weather)/i,
  /^what's?\s+(today|tomorrow|next week|on the news)/i,
  // Real-time information queries
  /^(what|where|who|how)\s+are\s+(the\s+)?(stock|crypto|price|exchange)/i,
  /^what's?\s+(trending|the\s+latest\s+(news|score|headline))/i,
  // Navigation/location - except document references like "appendix"
  /^(how\s+do\s+i\s+)?get\s+(to|directions|a\s+ride)/i,
  /^(what's|what\s+is)\s+near\s+me\b/i,
];

export const NO_CONTEXT_ANSWER =
  "I don't have information about that in your document.";

export const OUT_OF_SCOPE_ANSWER =
  "I can only answer questions about your uploaded document.";

export function isOutOfScopeQuestion(question: string): boolean {
  const normalized = question.toLowerCase();
  return OUT_OF_SCOPE_PATTERNS.some((pattern) => pattern.test(normalized));
}
