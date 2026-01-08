/**
 * Firebase Admin SDK Configuration
 * Initializes Firebase Admin SDK for server-side authentication and database access
 * Story 1.3: Configure Firebase Project Services
 */

import admin from "firebase-admin";
import { env } from "./env";

let initialized = false;

/**
 * Validate Firebase service account credentials structure
 * Ensures credentials have all required fields with valid formats
 */
function validateFirebaseCredentials(
  credentials: Record<string, unknown>
): void {
  // Validate credential type
  if (credentials.type !== "service_account") {
    throw new Error(
      `Invalid credential type: ${credentials.type}. Expected 'service_account'\"`
    );
  }

  // Validate required fields exist
  const requiredFields = [
    "project_id",
    "private_key",
    "client_email",
    "client_id",
  ];
  for (const field of requiredFields) {
    if (!credentials[field]) {
      throw new Error(
        `Missing required field in Firebase credentials: ${field}`
      );
    }
  }

  // Validate private key format (PEM)
  const privateKey = credentials.private_key as string;
  if (
    !privateKey.includes("-----BEGIN PRIVATE KEY-----") ||
    !privateKey.includes("-----END PRIVATE KEY-----")
  ) {
    throw new Error(
      "Invalid private key format. Expected PEM format with -----BEGIN PRIVATE KEY----- markers"
    );
  }

  // Validate client_email is valid email format
  const clientEmail = credentials.client_email as string;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(clientEmail)) {
    throw new Error(`Invalid client_email format: ${clientEmail}`);
  }
}

/**
 * Initialize Firebase Admin SDK
 * Configures Firebase with service account credentials for server-side operations
 * Uses env validation to ensure credentials are present before initialization
 * Follows singleton pattern - initializes only once
 */
function initializeFirebaseAdmin() {
  if (initialized) {
    return;
  }

  try {
    // Parse credentials from environment variable
    const credentialsJson =
      env.firebaseCredentials || env.firebaseServiceAccountKey;

    if (!credentialsJson) {
      throw new Error(
        "FIREBASE_CREDENTIALS or FIREBASE_SERVICE_ACCOUNT_KEY environment variable not set. " +
          "Please download the service account JSON from Firebase Console and set it in .env"
      );
    }

    // Parse JSON credentials
    let credentials: Record<string, unknown>;
    try {
      credentials = JSON.parse(credentialsJson);
    } catch (parseError) {
      throw new Error(
        "Failed to parse FIREBASE_CREDENTIALS as JSON. " +
          "Ensure the environment variable contains valid JSON from the Firebase service account key file. " +
          `Parse error: ${
            parseError instanceof Error ? parseError.message : "Unknown"
          }`
      );
    }

    // Validate credentials structure and format
    validateFirebaseCredentials(credentials);

    // Initialize Firebase Admin SDK
    admin.initializeApp({
      credential: admin.credential.cert(credentials as admin.ServiceAccount),
      projectId: credentials.project_id as string,
      storageBucket: `${credentials.project_id}.firebasestorage.app`,
    });

    initialized = true;
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    throw new Error(`Failed to initialize Firebase Admin SDK: ${message}`);
  }
}

// Initialize on module load
initializeFirebaseAdmin();

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
