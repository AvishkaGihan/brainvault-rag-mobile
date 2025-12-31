import * as admin from "firebase-admin";
import { env } from "./env";

/**
 * Initialize Firebase Admin SDK.
 * This ensures we have a singleton connection to Firebase services
 * throughout the application lifecycle.
 */
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.FIREBASE_PROJECT_ID,
        clientEmail: env.FIREBASE_CLIENT_EMAIL,
        privateKey: env.FIREBASE_PRIVATE_KEY,
      }),
      storageBucket: `${env.FIREBASE_PROJECT_ID}.appspot.com`,
    });
    console.info("✅ Firebase Admin Initialized successfully");
  } catch (error) {
    console.error("❌ Firebase Admin Initialization Error:", error);
    process.exit(1);
  }
}

// Export singleton instances of required services
export const auth = admin.auth();
export const db = admin.firestore();
export const storage = admin.storage();
