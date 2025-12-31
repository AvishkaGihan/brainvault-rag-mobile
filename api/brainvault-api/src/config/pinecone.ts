import { Pinecone } from "@pinecone-database/pinecone";
import { env } from "./env";

/**
 * Initialize the Pinecone client.
 * This connection is stateless and lightweight, used to access indexes.
 */
let pinecone: Pinecone;

try {
  pinecone = new Pinecone({
    apiKey: env.PINECONE_API_KEY,
  });
  console.info("✅ Pinecone Client Initialized");
} catch (error) {
  console.error("❌ Pinecone Initialization Error:", error);
  process.exit(1);
}

/**
 * Retrieves the configured Pinecone index instance.
 * * Index Configuration Requirements:
 * * Dimension: 768 (Matches Gemini embedding-001)
 * * Metric: Cosine
 * * Cloud: AWS (us-east-1 recommended for free tier)
 * * Namespace Strategy:
 * * We use namespaces to isolate user data.
 * * Pattern: `user_{userId}`
 */
export const getIndex = () => {
  return pinecone.index(env.PINECONE_INDEX_NAME);
};

export { pinecone };
