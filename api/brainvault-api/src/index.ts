import { Server } from "http";
import app from "./app";
import { env } from "./config/env";
import { logger } from "./config/logger";
import { db } from "./config/firebase";
import { getIndex } from "./config/pinecone";

let server: Server;

/**

* Bootstrap the application.
* 1. Validates environment variables (via config/env import)


* 2. Verifies external service connectivity


* 3. Starts the HTTP server
*/
const bootstrap = async () => {
  try {
    logger.info("Starting BrainVault API...");

    // 1. Verify Database Connectivity (Fail fast)
    // We do a simple listCollections to ensure creds work
    await db.listCollections();
    logger.info("✅ Firestore connected");
    // 2. Verify Vector DB Connectivity
    // Initialize client and check index existence
    const index = getIndex();
    await index.describeIndexStats();
    logger.info(`✅ Pinecone connected (Index: ${env.PINECONE_INDEX_NAME})`);
    // 3. Start HTTP Server
    // Render provides PORT env var, otherwise default to 3000
    const PORT = env.PORT || 3000;
    server = app.listen(PORT, () => {
      logger.info(`🚀 Server running on port ${PORT} in ${env.NODE_ENV} mode`);
      logger.info(`Health check available at http://localhost:${PORT}/health`);
    });
  } catch (error) {
    logger.error("❌ Fatal error during startup", error);
    process.exit(1);
  }
};

/**

* Graceful Shutdown Handler
* Ensures existing connections are closed before exiting.
*/
const shutdown = (signal: string) => {
  return () => {
    logger.info(`${signal} received. Shutting down gracefully...`);
    if (server) {
      server.close(() => {
        logger.info("HTTP server closed.");
        process.exit(0);
      });
    } else {
      process.exit(0);
    }
  };
};

// Handle termination signals
process.on("SIGTERM", shutdown("SIGTERM"));
process.on("SIGINT", shutdown("SIGINT"));

// Handle uncaught errors to prevent undefined state
process.on("uncaughtException", (error) => {
  logger.error("Uncaught Exception:", error);
  shutdown("SIGTERM")();
});

process.on("unhandledRejection", (reason) => {
  logger.error("Unhandled Rejection:", reason);
  shutdown("SIGTERM")();
});

// Start the app
bootstrap();
