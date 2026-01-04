import { Express } from "express";
import { healthRoutes } from "./health.routes";
import { authRoutes } from "./auth.routes";
import { documentsRoutes } from "./documents.routes";
import { chatRoutes } from "./chat.routes";

/**

* Configures and mounts all application routes.
* Establishes the API versioning and route hierarchy.
* @param app - The Express application instance
*/
export const setupRoutes = (app: Express): void => {
  // ---------------------------------------------------------------------------
  // System Routes
  // ---------------------------------------------------------------------------
  // Health check mounted at root level for infrastructure monitoring (AWS, Render, etc.)
  app.use("/health", healthRoutes);

  // ---------------------------------------------------------------------------
  // API V1 Routes
  // ---------------------------------------------------------------------------
  const V1_PREFIX = "/v1";

  // Authentication Routes
  // Handles /v1/auth/verify
  app.use(`${V1_PREFIX}/auth`, authRoutes);

  // Chat Routes
  // Mounted at /documents to support the nested resource structure: /v1/documents/:id/chat
  // Mounted BEFORE documentsRoutes to ensure specific sub-paths (like /:id/chat)
  // are handled before the generic /:id document retrieval route.
  app.use(`${V1_PREFIX}/documents`, chatRoutes);

  // Document Routes
  // Handles /v1/documents (List, Create) and /v1/documents/:id (Get, Delete, Status)
  app.use(`${V1_PREFIX}/documents`, documentsRoutes);
};
