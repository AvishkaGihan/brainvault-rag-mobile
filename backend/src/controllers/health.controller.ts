/**
 * Health Check Controller
 * Handles health status endpoint for monitoring
 */

import { Request, Response } from "express";
import { ApiResponse, HealthCheckData } from "../types";

const startTime = Date.now();

export class HealthController {
  /**
   * GET /health
   * Returns server health status
   */
  static health(req: Request, res: Response): void {
    const timestamp = new Date().toISOString();
    const uptime = Math.floor((Date.now() - startTime) / 1000);

    const data: HealthCheckData = {
      status: "ok",
      uptime,
      timestamp,
    };

    const response: ApiResponse<HealthCheckData> = {
      success: true,
      data,
      meta: {
        timestamp,
      },
    };

    res.status(200).json(response);
  }
}
