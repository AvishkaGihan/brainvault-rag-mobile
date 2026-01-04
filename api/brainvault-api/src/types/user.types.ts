import { Request } from "express";

/**
 * User & Authentication Type Definitions
 * This file defines the user entity structure and authentication-related types
 * used throughout the API. It bridges the gap between Firebase Auth identities
 * and our application-specific user profiles in Firestore.
 */

// ------------------------------------------------------------------
// Core User Entities
// ------------------------------------------------------------------

/**
 * Represents a registered user or guest in the system.
 * Mirrors the Firestore document structure at `/users/{userId}`.
 */
export interface User {
  /**
   * Unique identifier for the user.
   * Corresponds strictly to the Firebase Auth UID.
   */
  id: string;

  /**
   * User's email address.
   * Required for registered users, optional/undefined for guests.
   */
  email?: string;

  /** Display name for UI greeting */
  displayName?: string;

  /** Indicates if this is an anonymous guest account */
  isGuest: boolean;

  /**
   * Denormalized count of documents owned by this user.
   * Updated via triggers or service logic.
   */
  documentCount: number;

  /** Storage usage in bytes */
  storageUsage: number;

  /** User preferences */
  settings: UserSettings;

  /** ISO 8601 timestamp of account creation */
  createdAt: Date | string;

  /** ISO 8601 timestamp of last profile update */
  updatedAt: Date | string;
}

/**
 * User-configurable application settings.
 */
export interface UserSettings {
  /** UI Theme preference */
  theme: "light" | "dark" | "system";

  /** Language preference */
  language: string;
}

// ------------------------------------------------------------------
// Authentication Types
// ------------------------------------------------------------------

/**
 * Payload extracted from a verified Firebase ID token.
 */
export interface DecodedAuthToken {
  /** Firebase Auth UID */
  uid: string;

  /** Email address (if available) */
  email?: string;

  /** Auth provider (e.g., 'password', 'anonymous', 'google.com') */
  firebase: {
    sign_in_provider: string;
    [key: string]: unknown;
  };

  /** Token expiration time (seconds since epoch) */
  exp: number;
}

/**
 * Extension of the standard Express Request object.
 * Includes the authenticated user's details attached by middleware.
 */
export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email?: string;
    isAnonymous: boolean;
  };
}
