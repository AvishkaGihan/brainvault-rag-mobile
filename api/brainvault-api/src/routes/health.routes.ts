import { Router, Request, Response } from "express";
import { db } from "../config/firebase";
import { getIndex } from "../config/pinecone";
import { logger } from "../config/logger";

const router = Router();

/**

* GET /health
* System health check endpoint.
* Verifies connectivity to critical infrastructure (Firestore, Pinecone).
* Used by load balancers and deployment platforms (e.g., Render) to verify app readiness.
*/
router.get("/", async (req: Request, res: Response) => {
  const healthStatus = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    services: {
      database: "unknown",
      vectorDb: "unknown",
    },
  };

  let statusCode = 200;

  try {
    // 1. Check Firestore Connectivity
    // We perform a lightweight operation to verify the connection is active.
    try {
      // listing collections is a quick admin operation
      await db.listCollections();
      healthStatus.services.database = "connected";
    } catch (dbError) {
      logger.error("Health check: Firestore unreachable", dbError);
      healthStatus.services.database = "disconnected";
      healthStatus.status = "degraded";
      statusCode = 503; // Critical failure
    }

    // 2. Check Pinecone Connectivity
    // describeIndexStats is a standard lightweight call to check index responsiveness
    try {
      const index = getIndex();
      await index.describeIndexStats();
      healthStatus.services.vectorDb = "connected";
    } catch (pineconeError) {
      logger.error("Health check: Pinecone unreachable", pineconeError);
      healthStatus.services.vectorDb = "disconnected";
      // If vector DB is down, app is degraded but maybe not fully down (auth/metadata still works)
      if (healthStatus.status !== "degraded") {
        healthStatus.status = "degraded";
      }
    }

    // If critical DB is down, mark as 503 Service Unavailable
    if (healthStatus.services.database === "disconnected") {
      statusCode = 503;
    }

    res.status(statusCode).json({
      success: statusCode === 200 || statusCode === 503, // 503 is still a valid response object, just error code
      data: healthStatus,
    });
  } catch (error) {
    logger.error("Health check critical failure", error);
    res.status(500).json({
      success: false,
      message: "Health check failed internally",
    });
  }
});

export const healthRoutes = router;
