import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import { setupRoutes } from "./routes";
import { errorHandler } from "./middleware/error";
import { apiLimiter } from "./middleware/rate-limit";
import { logger } from "./config/logger";
import { AppError } from "./errors/app-error";
import { AuthenticatedRequest } from "./types/user.types";

const app = express();

// -----------------------------------------------------------------------------
// Global Middleware
// -----------------------------------------------------------------------------

// Security Headers
app.use(helmet());

// Cross-Origin Resource Sharing
// Allow all origins for mobile app compatibility (or configure specific origins in production)
app.use(cors());

// Body Parsing
// Increased limit to 10MB to handle larger payloads (though files use multipart)
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Request Logging
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  res.on("finish", () => {
    const duration = Date.now() - start;
    const userId = (req as AuthenticatedRequest).user?.uid || "anonymous";
    logger.http(
      `${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms [User: ${userId}]`
    );
  });
  next();
});

// Rate Limiting
// Applied globally to prevent abuse (DDoS protection)
app.use(apiLimiter);

// -----------------------------------------------------------------------------
// Routes
// -----------------------------------------------------------------------------

setupRoutes(app);

// -----------------------------------------------------------------------------
// Error Handling
// -----------------------------------------------------------------------------

// 404 Handler for unknown routes
app.use((req: Request, res: Response, next: NextFunction) => {
  next(
    new AppError(404, "ROUTE_NOT_FOUND", `Route not found: ${req.originalUrl}`)
  );
});

// Global Error Handler
// Must be the last middleware registered
app.use(errorHandler);

export default app;
