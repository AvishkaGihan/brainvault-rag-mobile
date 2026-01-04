import { Router, Response } from "express";
import { authenticateToken } from "../middleware/auth";
import { userService } from "../services/user.service";
import { AuthenticatedRequest } from "../types/user.types";
import { logger } from "../config/logger";
import { AppError } from "../errors/app-error";

const router = Router();

/**

* POST /verify
* Verifies the Firebase ID token (via middleware) and ensures a corresponding
* user record exists in Firestore.
* Usage: Called by the mobile app immediately after Firebase Authentication completes.
* * If user exists: Returns user profile.


* * If user is new: Creates Firestore record and returns new profile.


* Headers:
* Authorization: Bearer <firebase_id_token>
*/
router.post(
  "/verify",
  authenticateToken,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      // Req.user is populated by authenticateToken middleware
      const { uid, email, isAnonymous } = req.user!;
      logger.info(`Verifying user: ${uid} (Anonymous: ${isAnonymous})`);
      // 1. Check if user exists in Firestore
      let user = await userService.getUser(uid);
      // 2. If not, create new user record
      if (!user) {
        // For anonymous users, email might be null/undefined
        const userEmail =
          email || `guest_${uid.substring(0, 8)}@brainvault.app`;
        user = await userService.createUser(uid, userEmail, isAnonymous);
      }
      // 3. Return user profile
      res.status(200).json({
        success: true,
        data: {
          user,
        },
      });
    } catch (error) {
      logger.error("Auth verification failed", error);
      // Pass to global error handler if it's an AppError, otherwise wrap it
      if (error instanceof AppError) throw error;
      throw new AppError(
        500,
        "AUTH_VERIFICATION_FAILED",
        "Authentication verification failed"
      );
    }
  }
);

export const authRoutes = router;
