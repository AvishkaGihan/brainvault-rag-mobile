/**
 * BrainVault API Type Definitions
 * This file serves as the central export point for all TypeScript interfaces
 * and types used throughout the backend application.
 * Consumers should import types from this barrel file rather than
 * individual type files to ensure consistent access.
 * @module Types
 */

// Export standard API response wrappers and error codes
export * from "./api.types";

// Export document entities and processing status types
export * from "./document.types";

// Export chat, message, and RAG-related types
export * from "./chat.types";

// Export user and authentication types
export * from "./user.types";
