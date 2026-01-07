/**
 * Route Aggregator
 * Centralizes all route definitions
 */

import { Router } from "express";
import healthRoutes from "./health.routes";

const router = Router();

/**
 * Health check routes
 */
router.use("/health", healthRoutes);

export default router;
