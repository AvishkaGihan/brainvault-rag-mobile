import { Request, Response, NextFunction } from "express";
import { ZodError, ZodTypeAny, ZodIssue } from "zod";
import { AppError } from "../errors/app-error";

/**
 * Middleware factory to validate incoming requests against a Zod schema.
 * Validates req.body, req.query, and req.params.
 *
 * @param schema - The Zod schema defining the expected request shape (body, query, params)
 * @returns Express middleware function
 */
export const validate = (schema: ZodTypeAny) => {
  return async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      // Validate the request against the schema
      // We pass the relevant parts of the request to match typical Zod usage for Express
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });

      next();
    } catch (error) {
      if (error instanceof ZodError) {
        // Transform Zod errors into a user-friendly format
        // Structure: { fieldName: ["Error message 1", "Error message 2"] }
        const fieldErrors: Record<string, string[]> = {};

        error.issues.forEach((err: ZodIssue) => {
          // The path usually looks like ["body", "fieldName"] or ["query", "fieldName"]
          // We want to extract the field name for the frontend
          // If the path has at least 2 segments (e.g. body.email), use the second segment
          // Otherwise fall back to the last segment or "unknown"
          const path = err.path;
          let fieldName = "unknown";

          if (path.length >= 2) {
            // Example: path is ["body", "email"] -> fieldName = "email"
            fieldName = path[1].toString();
          } else if (path.length === 1) {
            fieldName = path[0].toString();
          }

          if (!fieldErrors[fieldName]) {
            fieldErrors[fieldName] = [];
          }
          fieldErrors[fieldName].push(err.message);
        });

        // Throw AppError with VALIDATION_ERROR code and details
        // The global error handler will format this into the final JSON response
        const validationError = new AppError(
          400,
          "VALIDATION_ERROR",
          "Validation failed",
          fieldErrors
        );

        next(validationError);
        return;
      }

      // Pass other errors to the global error handler
      next(error);
    }
  };
};
