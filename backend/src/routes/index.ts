/**
 * Route Aggregator
 * Centralizes all route definitions
 */

import { Router } from "express";
import { router as healthRoutes } from "./health.routes";

const router = Router();

/**
 * Health check routes
 */
router.use("/health", healthRoutes);

export { router };
