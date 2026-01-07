/**
 * Firebase Admin SDK Configuration
 * Initializes Firebase Admin SDK for server-side authentication and database access
 * Placeholder for Story 1.3: Configure Firebase Project Services
 */

import admin from "firebase-admin";
import { env } from "./env";

/**
 * Initialize Firebase Admin SDK
 * Configures Firebase with service account credentials for server-side operations
 * Uses env validation to ensure credentials are present before initialization
 */
try {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.firebaseProjectId,
      privateKey: env.firebasePrivateKey.replace(/\\n/g, "\n"),
      clientEmail: env.firebaseClientEmail,
    }),
  });
} catch (error) {
  const message = error instanceof Error ? error.message : "Unknown error";
  throw new Error(`Failed to initialize Firebase Admin SDK: ${message}`);
}

/**
 * Firebase Auth instance for user authentication operations
 */
export const auth = admin.auth();

/**
 * Firestore database instance for document operations
 */
export const firestore = admin.firestore();

/**
 * Cloud Storage bucket instance for file operations
 */
export const storage = admin.storage().bucket();
