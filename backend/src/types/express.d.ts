/**
 * Express Request Type Extension
 * Adds user property to Express Request for authenticated requests
 *
 * Story: 2.7 - Backend Auth Middleware
 * Purpose: Type-safe access to authenticated user data
 */

declare global {
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email?: string;
      };
    }
  }
}

export {};
