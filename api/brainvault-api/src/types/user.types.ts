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
 * Mirrors the Firestore document structure at 'users/{userId}'.
 */
export interface User {
  /**
   * Unique identifier for the user.
   * Corresponds strictly to the Firebase Auth UID.
   */
  id:string;

  /**
   * User's email address.
   * Required for registered users; optional/undefined for guests.
   */
  email?: string;

  /** Display name for UI greeting */
  displayName: string;

  /** Indicate if this is an anonymous guest account */
  isGuest: boolean;

  
}

export interface UserSettings {}

// ------------------------------------------------------------------
// Authentication Types
// ------------------------------------------------------------------`
export interface DecodedAuthToken {}

export interface AuthenticatedRequest extends Request {}
