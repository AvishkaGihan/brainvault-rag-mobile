/**
 * Firebase Admin SDK Configuration
 * Initializes Firebase Admin SDK for server-side authentication and database access
 * Placeholder for Story 1.3: Configure Firebase Project Services
 */

import admin from "firebase-admin";
import dotenv from "dotenv";
dotenv.config();

/**
 * Initialize Firebase Admin SDK
 * Configures Firebase with service account credentials for server-side operations
 */
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  }),
});

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
