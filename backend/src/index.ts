/**
 * BrainVault RAG API - Main Entry Point
 * Express server initialization with middleware setup
 */

import express, { Express } from "express";
import cors from "cors";
import { env } from "./config/env";
import { router } from "./routes";
import { errorHandler, notFoundHandler } from "./middleware/error.middleware";

/**
 * Initialize Express application
 */
function createApp(): Express {
  const app = express();

  // Middleware: Body Parser
  app.use(express.json({ limit: "10mb" }));
  app.use(express.urlencoded({ limit: "10mb", extended: true }));

  // Middleware: CORS
  // Configure CORS for local development and production origins
  const corsOptions = {
    origin: (
      origin: string | undefined,
      callback: (err: Error | null, allow?: boolean) => void
    ) => {
      const allowedOrigins = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
      ];

      // Allow requests with no origin (mobile apps, curl, etc)
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else if (env.nodeEnv === "development") {
        // In development, allow all origins for easier testing
        callback(null, true);
      } else {
        callback(new Error("CORS policy violation"));
      }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  };

  app.use(cors(corsOptions));

  // Middleware: Request logging (development)
  if (env.nodeEnv === "development") {
    app.use((req, res, next) => {
      console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
      next();
    });
  }

  // Routes
  app.use("/api", router);

  // 404 Handler
  app.use(notFoundHandler);

  // Error Handler (MUST be last)
  app.use(errorHandler);

  return app;
}

/**
 * Start the server
 */
async function startServer(): Promise<void> {
  try {
    const app = createApp();
    const port = env.port;
    const host = "0.0.0.0";

    app.listen(port, host, () => {
      console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║           🧠 BrainVault RAG API Started               ║
║                                                        ║
║  Server:     http://localhost:${port.toString().padEnd(39)}║
║  Environment: ${env.nodeEnv.padEnd(40)}║
║  Status:     ✓ Ready to accept requests              ║
║                                                        ║
║  Health Check: GET /api/health                        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

// Start server
startServer();
