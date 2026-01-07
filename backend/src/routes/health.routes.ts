/**
 * Health Check Routes
 * Endpoint for monitoring server status
 */

import { Router } from "express";
import { HealthController } from "../controllers/health.controller";

const router = Router();

/**
 * GET /health
 * Returns server health status
 *
 * Response: { success: true, data: { status: "ok", uptime: 123, timestamp: "..." }, meta: { timestamp: "..." } }
 */
router.get("/", HealthController.health);

export { router };
