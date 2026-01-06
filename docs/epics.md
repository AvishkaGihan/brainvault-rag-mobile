---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: ['prd.md', 'architecture.md', 'ux-design-specification.md']
workflowType: 'epics'
lastStep: 4
status: complete
completedAt: '2026-01-05'
totalEpics: 6
totalStories: 43
frCoverage: '41/41'
---

# BrainVault - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for BrainVault, decomposing the requirements from the PRD, UX Design, and Architecture documents into implementable stories.

## Requirements Inventory

### Functional Requirements

**User Authentication (FR1-FR6)**
- FR1: User can create an account using email and password
- FR2: User can log in with existing email and password credentials
- FR3: User can continue as a guest without creating an account
- FR4: User can log out of their account
- FR5: User can reset their password via email
- FR6: System maintains user session across app restarts

**Document Ingestion (FR7-FR14)**
- FR7: User can upload a PDF file from their device
- FR8: System accepts PDF files up to 5MB in size
- FR9: System rejects PDF files exceeding 5MB with clear error message
- FR10: User can paste plain text directly into the app as a document
- FR11: System displays processing status while document is being ingested
- FR12: System notifies user when document processing is complete
- FR13: System displays error message if document processing fails
- FR14: User can cancel document upload before processing completes

**Knowledge Processing - Backend (FR15-FR20)**
- FR15: System extracts text content from uploaded PDF files
- FR16: System splits document text into semantic chunks
- FR17: System generates vector embeddings for each chunk
- FR18: System stores embeddings with metadata (document ID, page number)
- FR19: System preserves page number information for source attribution
- FR20: System associates all document data with the uploading user

**Chat & Retrieval (FR21-FR30)**
- FR21: User can enter a natural language question about a document
- FR22: System retrieves the top 3 most relevant context chunks for a query
- FR23: System generates an answer using retrieved context and LLM
- FR24: System displays source citation (page number) with each answer
- FR25: User can tap source citation to identify the referenced page
- FR26: System responds with "I don't have information about that" when context is insufficient
- FR27: User can view chat history for the current document session
- FR28: System persists chat history per document
- FR29: User can start a new conversation within the same document
- FR30: System displays "Thinking..." indicator while generating response

**Document Management (FR31-FR36)**
- FR31: User can view a list of all their uploaded documents
- FR32: User can select a document to enter its chat interface
- FR33: User can delete a document from their knowledge base
- FR34: System confirms deletion before removing document
- FR35: User can see document metadata (name, upload date, size)
- FR36: System displays documents in reverse chronological order (newest first)

**System Feedback & Error Handling (FR37-FR41)**
- FR37: System displays appropriate loading indicators during all async operations
- FR38: System displays user-friendly error messages for all failure scenarios
- FR39: User can retry failed operations (upload, query)
- FR40: System gracefully handles network disconnection during operations
- FR41: System provides clear feedback when user exceeds free tier limits

### Non-Functional Requirements

**Performance (NFR1-NFR5)**
- NFR1: Query response time (end-to-end) P95 < 5 seconds [Critical]
- NFR2: Document processing time (5MB PDF) < 30 seconds [High]
- NFR3: App cold start time < 2 seconds [High]
- NFR4: Document list load time < 500ms [Medium]
- NFR5: Time to first meaningful paint < 1 second [Medium]

**Security (NFR6-NFR11)**
- NFR6: API keys never stored in mobile app code [Critical]
- NFR7: User documents isolated per user account [Critical]
- NFR8: All API communication over HTTPS [Critical]
- NFR9: Firebase Auth tokens validated on every API call [Critical]
- NFR10: User can delete their documents and associated data [High]
- NFR11: No PII logged in application logs [High]

**Reliability (NFR12-NFR15)**
- NFR12: Document upload success rate 99% for valid PDFs (≤5MB) [Critical]
- NFR13: Chat query availability 99% uptime during demo hours [High]
- NFR14: Graceful degradation on service failure [High]
- NFR15: Data persistence - No data loss after successful upload [Critical]

**Usability (NFR16-NFR20)**
- NFR16: Time to first successful query < 3 minutes from app open [High]
- NFR17: Guest mode zero-friction - no signup required to try [Critical]
- NFR18: Loading states for all async operations 100% coverage [High]
- NFR19: Error messages actionable - user knows what to do next [High]
- NFR20: Mobile-first responsive design - works on phones 5"+ [High]

**Scalability (NFR21-NFR23)**
- NFR21: Support 10 concurrent users [Low]
- NFR22: Up to 20 documents per user [Low]
- NFR23: Pinecone free tier limits - 100,000 vectors total [Informational]

**Maintainability (NFR24-NFR27)**
- NFR24: LLM provider swappable via config-based provider selection [High]
- NFR25: Clean code architecture - feature-based folder structure [Medium]
- NFR26: Environment-based configuration - .env files for all environments [High]
- NFR27: Code documentation - README with setup instructions [Critical]

**Accessibility (NFR28-NFR30)**
- NFR28: Minimum touch target size 48x48 dp [Medium]
- NFR29: Color contrast ratio 4.5:1 minimum [Medium]
- NFR30: Screen reader compatibility - core flows accessible [Low]

### Additional Requirements

**From Architecture Document:**
- ARCH-1: **Starter Template Required** - Flutter: `flutter create --org com.avishkagihan --project-name brainvault brainvault_app`; Node.js: Custom Express + TypeScript setup
- ARCH-2: Feature-first folder structure with Clean Architecture layers (data/domain/presentation)
- ARCH-3: Riverpod for state management with AsyncValue for async operations
- ARCH-4: Dio for HTTP client with auth interceptors
- ARCH-5: GoRouter for declarative navigation
- ARCH-6: Firestore hybrid schema - flat collections with logical subcollections
- ARCH-7: Single Pinecone index with composite metadata filtering (userId, documentId, pageNumber)
- ARCH-8: Firebase Anonymous Auth for guest mode with account linking capability
- ARCH-9: Firebase JWT verification + rate limiting middleware
- ARCH-10: LangChain RecursiveCharacterTextSplitter (1000 chars, 200 overlap)
- ARCH-11: text-embedding-004 (Gemini) for embeddings - 768 dimensions
- ARCH-12: LangChain RetrievalQA with strict prompt engineering for hallucination prevention
- ARCH-13: Config-based LLM provider switching (Gemini/OpenAI/Anthropic)
- ARCH-14: Railway for backend hosting
- ARCH-15: SharedPreferences for document list caching, in-memory for chat

**From UX Design Document:**
- UX-1: Material Design 3 (Material You) design system
- UX-2: Custom chat message bubbles with branded styling
- UX-3: Source citation chips using Tertiary Container colors
- UX-4: Streaming text response pattern (word-by-word appearance)
- UX-5: Skeleton loaders for document list loading states
- UX-6: 48dp minimum touch targets throughout
- UX-7: Light and dark mode support
- UX-8: Brand colors: Primary #6750A4 (Deep Purple), Tertiary #7D5260 (Dusty Rose)
- UX-9: Roboto font family with defined type scale
- UX-10: 8dp base spacing unit
- UX-11: Pull-to-refresh for document list
- UX-12: FAB for primary "New Document" action
- UX-13: Bottom navigation: Documents, Chat, Settings
- UX-14: Error states with friendly copy and clear recovery actions
- UX-15: "Thinking..." indicator with italic, muted styling
- UX-16: Success celebration animations (subtle)

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 2 | User can create an account using email and password |
| FR2 | Epic 2 | User can log in with existing email and password credentials |
| FR3 | Epic 2 | User can continue as a guest without creating an account |
| FR4 | Epic 2 | User can log out of their account |
| FR5 | Epic 2 | User can reset their password via email |
| FR6 | Epic 2 | System maintains user session across app restarts |
| FR7 | Epic 3 | User can upload a PDF file from their device |
| FR8 | Epic 3 | System accepts PDF files up to 5MB in size |
| FR9 | Epic 3 | System rejects PDF files exceeding 5MB with clear error message |
| FR10 | Epic 3 | User can paste plain text directly into the app as a document |
| FR11 | Epic 3 | System displays processing status while document is being ingested |
| FR12 | Epic 3 | System notifies user when document processing is complete |
| FR13 | Epic 3 | System displays error message if document processing fails |
| FR14 | Epic 3 | User can cancel document upload before processing completes |
| FR15 | Epic 3 | System extracts text content from uploaded PDF files |
| FR16 | Epic 3 | System splits document text into semantic chunks |
| FR17 | Epic 3 | System generates vector embeddings for each chunk |
| FR18 | Epic 3 | System stores embeddings with metadata (document ID, page number) |
| FR19 | Epic 3 | System preserves page number information for source attribution |
| FR20 | Epic 3 | System associates all document data with the uploading user |
| FR21 | Epic 5 | User can enter a natural language question about a document |
| FR22 | Epic 5 | System retrieves the top 3 most relevant context chunks for a query |
| FR23 | Epic 5 | System generates an answer using retrieved context and LLM |
| FR24 | Epic 5 | System displays source citation (page number) with each answer |
| FR25 | Epic 5 | User can tap source citation to identify the referenced page |
| FR26 | Epic 5 | System responds with "I don't have information about that" when context is insufficient |
| FR27 | Epic 5 | User can view chat history for the current document session |
| FR28 | Epic 5 | System persists chat history per document |
| FR29 | Epic 5 | User can start a new conversation within the same document |
| FR30 | Epic 5 | System displays "Thinking..." indicator while generating response |
| FR31 | Epic 4 | User can view a list of all their uploaded documents |
| FR32 | Epic 4 | User can select a document to enter its chat interface |
| FR33 | Epic 4 | User can delete a document from their knowledge base |
| FR34 | Epic 4 | System confirms deletion before removing document |
| FR35 | Epic 4 | User can see document metadata (name, upload date, size) |
| FR36 | Epic 4 | System displays documents in reverse chronological order (newest first) |
| FR37 | Epic 6 | System displays appropriate loading indicators during all async operations |
| FR38 | Epic 6 | System displays user-friendly error messages for all failure scenarios |
| FR39 | Epic 6 | User can retry failed operations (upload, query) |
| FR40 | Epic 6 | System gracefully handles network disconnection during operations |
| FR41 | Epic 6 | System provides clear feedback when user exceeds free tier limits |

## Epic List

### Epic 1: Project Foundation & Infrastructure Setup

Establish the foundational codebases, configurations, and infrastructure required for all subsequent development. Development environment ready with both Flutter app and Node.js backend scaffolded, Firebase and Pinecone configured, and deployment pipeline established.

**FRs covered:** None (Technical foundation enabling all FRs)
**Additional Requirements:** ARCH-1, ARCH-2, ARCH-5, ARCH-6, ARCH-7, ARCH-14, ARCH-15, NFR6, NFR8, NFR26, NFR27

---

### Epic 2: User Authentication & Session Management

Enable users to securely access the application with zero-friction guest mode or persistent email accounts. Users can sign up, log in, continue as guest, and maintain sessions across app restarts. Guest users can upgrade to full accounts while preserving their data.

**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6
**Additional Requirements:** ARCH-3, ARCH-4, ARCH-8, ARCH-9, NFR7, NFR9, NFR17, UX-7

---

### Epic 3: Document Upload & Processing

Enable users to add documents to their knowledge vault and have them processed for AI-powered queries. Users can upload PDFs (≤5MB) or paste text, see processing progress, and receive confirmation when documents are ready for querying. Error states are clearly communicated.

**FRs covered:** FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR15, FR16, FR17, FR18, FR19, FR20
**Additional Requirements:** ARCH-10, ARCH-11, NFR2, NFR12, NFR15, UX-5, UX-12, UX-16

---

### Epic 4: Document Management & Library

Enable users to view, organize, and manage their uploaded documents. Users can browse their document library, see metadata (name, date, size), select documents for chat, and delete unwanted documents with confirmation.

**FRs covered:** FR31, FR32, FR33, FR34, FR35, FR36
**Additional Requirements:** ARCH-15, NFR4, NFR10, UX-5, UX-11, UX-13

---

### Epic 5: AI Chat & RAG-Powered Q&A

Enable users to have natural language conversations with their documents and receive accurate, cited answers. Users can ask questions about a selected document, receive AI-generated answers with page citations, view chat history, and start new conversations. The system gracefully handles cases where information isn't available.

**FRs covered:** FR21, FR22, FR23, FR24, FR25, FR26, FR27, FR28, FR29, FR30
**Additional Requirements:** ARCH-12, ARCH-13, NFR1, NFR13, UX-2, UX-3, UX-4, UX-15

---

### Epic 6: Error Handling, Loading States & Polish

Ensure professional UX quality with comprehensive feedback, error handling, and visual polish throughout the app. Users always know what's happening (loading states), receive helpful error messages with recovery actions, and experience a polished, trustworthy application.

**FRs covered:** FR37, FR38, FR39, FR40, FR41
**Additional Requirements:** NFR3, NFR5, NFR14, NFR18, NFR19, NFR20, UX-1, UX-6, UX-8, UX-9, UX-10, UX-14, NFR28, NFR29

---

## Epic 1: Project Foundation & Infrastructure Setup

Establish the foundational codebases, configurations, and infrastructure required for all subsequent development. Development environment ready with both Flutter app and Node.js backend scaffolded, Firebase and Pinecone configured, and deployment pipeline established.

### Story 1.1: Initialize Flutter Mobile Application

As a developer,
I want a properly structured Flutter project with all core dependencies configured,
So that I can build features using consistent patterns and architecture.

**Acceptance Criteria:**

**Given** no existing Flutter project
**When** I run the initialization commands
**Then** a Flutter project is created with org `com.avishkagihan` and name `brainvault`
**And** the project compiles and runs on Android emulator without errors
**And** the folder structure follows feature-first Clean Architecture:
  - `lib/app/` for app configuration and routes
  - `lib/features/` for feature modules (auth, documents, chat)
  - `lib/core/` for shared utilities, theme, network
  - `lib/shared/widgets/` for reusable components
**And** the following dependencies are configured in pubspec.yaml:
  - flutter_riverpod (state management)
  - dio (HTTP client)
  - go_router (navigation)
  - firebase_core, firebase_auth (Firebase)
  - file_picker (document selection)
**And** GoRouter is configured with placeholder routes for auth, home, and chat screens
**And** Material Design 3 theme is configured with the brand color palette (#6750A4 primary)
**And** a README.md exists with setup instructions

---

### Story 1.2: Initialize Node.js Backend API

As a developer,
I want a properly structured Node.js/Express backend with TypeScript configured,
So that I can build API endpoints using consistent patterns.

**Acceptance Criteria:**

**Given** no existing backend project
**When** I initialize the Node.js project
**Then** a TypeScript Express project is created in `brainvault-api/` folder
**And** the project compiles without TypeScript errors
**And** the folder structure follows service-oriented architecture:
  - `src/config/` for environment and service configurations
  - `src/routes/` for API route definitions
  - `src/controllers/` for request handlers
  - `src/services/` for business logic
  - `src/middleware/` for auth and error handling
  - `src/types/` for TypeScript interfaces
**And** the following dependencies are installed:
  - express, typescript, ts-node, nodemon
  - langchain, @langchain/google-genai
  - @pinecone-database/pinecone
  - firebase-admin, multer, pdf-parse, cors, dotenv
**And** a `.env.example` file documents all required environment variables
**And** a health check endpoint exists at `GET /health` returning `{ status: "ok" }`
**And** nodemon is configured for development hot-reload
**And** CORS is configured to allow requests from localhost

---

### Story 1.3: Configure Firebase Project & Services

As a developer,
I want Firebase services configured for both mobile and backend,
So that I can implement authentication and data storage features.

**Acceptance Criteria:**

**Given** a new Firebase project created in Firebase Console
**When** I configure Firebase for BrainVault
**Then** Firebase Authentication is enabled with Email/Password and Anonymous providers
**And** Cloud Firestore is created in production mode
**And** Firebase Storage is enabled with default bucket
**And** Firestore security rules are configured to:
  - Allow authenticated users to read/write only their own documents
  - Deny all access to unauthenticated users (except anonymous auth)
**And** Firestore indexes are created for:
  - `documents` collection: `userId` (ascending), `createdAt` (descending)
**And** Firebase Admin SDK service account JSON is downloaded
**And** Flutter app has `firebase_options.dart` generated via FlutterFire CLI
**And** Backend has Firebase Admin SDK initialized and verified with a test connection
**And** Storage rules allow authenticated users to upload to `users/{userId}/documents/`

---

### Story 1.4: Configure Pinecone Vector Database

As a developer,
I want Pinecone vector database configured and connected,
So that I can store and query document embeddings.

**Acceptance Criteria:**

**Given** a Pinecone account with free tier access
**When** I configure Pinecone for BrainVault
**Then** an index named `brainvault-index` is created with:
  - Dimension: 768 (matching text-embedding-004)
  - Metric: cosine
  - Cloud: AWS, Region: us-east-1 (free tier)
**And** the Pinecone client is configured in backend `src/config/pinecone.ts`
**And** the metadata schema supports: `userId`, `documentId`, `pageNumber`, `chunkIndex`, `textPreview`
**And** a test script verifies:
  - Connection to Pinecone succeeds
  - Upsert operation works with sample vector
  - Query operation returns results with metadata
  - Delete operation removes test vectors
**And** environment variables `PINECONE_API_KEY` and `PINECONE_INDEX` are documented

---

### Story 1.5: Deploy Backend to Railway

As a developer,
I want the backend deployed to Railway with proper configuration,
So that the mobile app can communicate with production APIs.

**Acceptance Criteria:**

**Given** a Railway account and the backend codebase
**When** I deploy the backend
**Then** the backend is deployed via Git push to Railway
**And** all environment variables are configured in Railway dashboard:
  - NODE_ENV=production
  - Firebase credentials (PROJECT_ID, PRIVATE_KEY, CLIENT_EMAIL)
  - PINECONE_API_KEY, PINECONE_INDEX
  - GOOGLE_API_KEY (for Gemini)
  - LLM_PROVIDER=gemini
**And** the health check endpoint is accessible via HTTPS at the Railway URL
**And** the deployment includes automatic restarts on failure
**And** the backend URL is documented for Flutter app configuration
**And** CORS is updated to allow requests from production origins

---

## Epic 2: User Authentication & Session Management

Enable users to securely access the application with zero-friction guest mode or persistent email accounts. Users can sign up, log in, continue as guest, and maintain sessions across app restarts. Guest users can upgrade to full accounts while preserving their data.

### Story 2.1: Implement Guest Mode Authentication

As a first-time user,
I want to continue as a guest without creating an account,
So that I can try the app immediately without friction.

**Acceptance Criteria:**

**Given** I am on the authentication screen
**When** I tap "Continue as Guest"
**Then** Firebase Anonymous Authentication is triggered
**And** I receive a valid Firebase UID (even as anonymous user)
**And** I am navigated to the home screen
**And** I can access all app features (upload, chat)
**And** my session persists if I close and reopen the app
**And** a "Thinking..." or loading indicator shows during authentication
**And** if authentication fails, a user-friendly error message is displayed with retry option

**Technical Notes:**
- Uses `FirebaseAuth.instance.signInAnonymously()`
- Anonymous UID is used for all backend API calls
- Session token is stored securely

---

### Story 2.2: Implement Email/Password Registration

As a new user,
I want to create an account with my email and password,
So that I can access my documents from any device.

**Acceptance Criteria:**

**Given** I am on the authentication screen
**When** I tap "Sign Up" and enter valid email and password
**Then** a new Firebase account is created with my credentials
**And** I am automatically logged in after registration
**And** I am navigated to the home screen
**And** my user profile is created in Firestore `users/{userId}` collection
**And** password must be at least 6 characters
**And** email format is validated before submission
**And** if email is already registered, a clear error message is shown
**And** if registration fails, a user-friendly error message is displayed

**Given** I entered an invalid email format
**When** I tap "Sign Up"
**Then** validation error is shown inline without API call

---

### Story 2.3: Implement Email/Password Login

As a returning user,
I want to log in with my email and password,
So that I can access my existing documents.

**Acceptance Criteria:**

**Given** I have an existing account
**When** I enter my email and password and tap "Sign In"
**Then** I am authenticated with Firebase
**And** I am navigated to the home screen
**And** my session persists across app restarts
**And** a loading indicator shows during authentication

**Given** I enter incorrect credentials
**When** I tap "Sign In"
**Then** a user-friendly error message is shown ("Invalid email or password")
**And** I can retry with different credentials

**Given** I enter an email that doesn't exist
**When** I tap "Sign In"
**Then** the same generic error is shown (security: don't reveal if email exists)

---

### Story 2.4: Implement Session Persistence & Auto-Login

As a returning user,
I want to stay logged in across app restarts,
So that I don't have to authenticate every time.

**Acceptance Criteria:**

**Given** I was previously logged in (guest or email)
**When** I open the app
**Then** my session is automatically restored from Firebase
**And** I am navigated directly to the home screen (skip auth screen)
**And** my Firebase token is refreshed if needed
**And** this happens within 2 seconds of app launch

**Given** my session token has expired
**When** I open the app
**Then** Firebase automatically refreshes the token
**And** I remain logged in without re-entering credentials

**Given** I was not previously logged in
**When** I open the app
**Then** I am shown the authentication screen

---

### Story 2.5: Implement User Logout

As a logged-in user,
I want to log out of my account,
So that I can secure my data or switch accounts.

**Acceptance Criteria:**

**Given** I am logged in (guest or email)
**When** I tap "Log Out" in settings
**Then** a confirmation dialog appears: "Are you sure you want to log out?"
**And** if I confirm, my Firebase session is terminated
**And** local cached data is cleared
**And** I am navigated to the authentication screen
**And** I cannot access protected screens without re-authenticating

**Given** I am a guest user
**When** I log out
**Then** I am warned: "As a guest, logging out will delete all your data. Create an account to save your documents."
**And** I can choose to "Create Account" or "Log Out Anyway"

---

### Story 2.6: Implement Password Reset

As a user who forgot my password,
I want to reset my password via email,
So that I can regain access to my account.

**Acceptance Criteria:**

**Given** I am on the login screen
**When** I tap "Forgot Password?" and enter my email
**Then** Firebase sends a password reset email to that address
**And** a confirmation message is shown: "Reset link sent to your email"
**And** I can return to the login screen

**Given** I enter an email that doesn't exist
**When** I request password reset
**Then** the same success message is shown (security: don't reveal if email exists)
**And** no email is actually sent

**Given** I received the reset email
**When** I click the link and set a new password
**Then** I can log in with my new password

---

### Story 2.7: Implement Backend Auth Middleware

As the system,
I want all API endpoints protected by authentication,
So that users can only access their own data.

**Acceptance Criteria:**

**Given** an API request with a valid Firebase JWT token
**When** the request reaches the backend
**Then** the auth middleware extracts and verifies the token
**And** `req.user.uid` is populated with the user's Firebase UID
**And** the request proceeds to the controller

**Given** an API request without a token
**When** the request reaches the backend
**Then** a 401 response is returned: `{ error: "No token provided" }`

**Given** an API request with an invalid/expired token
**When** the request reaches the backend
**Then** a 401 response is returned: `{ error: "Invalid token" }`

**And** the middleware is applied to all routes except `/health`
**And** rate limiting is configured: 100 requests per 15 minutes per user

---

## Epic 3: Document Upload & Processing

Enable users to add documents to their knowledge vault and have them processed for AI-powered queries. Users can upload PDFs (≤5MB) or paste text, see processing progress, and receive confirmation when documents are ready for querying.

### Story 3.1: Implement PDF File Selection UI

As a user,
I want to select a PDF file from my device,
So that I can upload it to my knowledge vault.

**Acceptance Criteria:**

**Given** I am on the home screen
**When** I tap the FAB (Floating Action Button) "+"
**Then** a bottom sheet appears with options: "Upload PDF" and "Paste Text"

**Given** I selected "Upload PDF"
**When** the file picker opens
**Then** I can browse and select PDF files from my device
**And** only PDF files are selectable (filter applied)
**And** after selection, the file name and size are displayed
**And** if the file exceeds 5MB, an error is shown: "File too large. Maximum size is 5MB."
**And** a "Upload" button is available to proceed

**Given** I cancel the file picker
**When** I return to the app
**Then** no file is selected and I remain on the home screen

---

### Story 3.2: Implement Text Paste Input UI

As a user,
I want to paste plain text directly into the app,
So that I can add content without having a PDF file.

**Acceptance Criteria:**

**Given** I selected "Paste Text" from the upload options
**When** the text input screen appears
**Then** I see a large text area with placeholder: "Paste or type your text here..."
**And** I can paste text from clipboard or type directly
**And** a character count is displayed
**And** I can provide a title for the text document
**And** a "Save" button is available when text is not empty

**Given** I paste text exceeding 50,000 characters
**When** I try to save
**Then** an error is shown: "Text too long. Maximum 50,000 characters."

**Given** I tap "Save" with valid text
**When** the text is submitted
**Then** a processing indicator appears
**And** the text is sent to the backend for processing

---

### Story 3.3: Implement Document Upload API Endpoint

As the system,
I want an API endpoint to receive uploaded documents,
So that I can process them for the RAG pipeline.

**Acceptance Criteria:**

**Given** an authenticated user with a PDF file
**When** a POST request is made to `/api/v1/documents/upload`
**Then** the file is received via multipart form-data
**And** the file is validated:
  - Must be PDF (MIME type check)
  - Must be ≤ 5MB
  - Must have valid PDF header
**And** the file is uploaded to Firebase Storage at `users/{userId}/documents/{documentId}.pdf`
**And** a document record is created in Firestore with status: "processing"
**And** response returns: `{ documentId, status: "processing" }`

**Given** an invalid file (wrong type or too large)
**When** upload is attempted
**Then** a 400 response is returned with specific error message
**And** no file is stored

**Given** a text-only document (from paste)
**When** a POST request is made to `/api/v1/documents/text`
**Then** the text content is accepted in JSON body
**And** the text is stored directly (no file upload needed)
**And** a document record is created with status: "processing"

---

### Story 3.4: Implement PDF Text Extraction

As the system,
I want to extract text content from uploaded PDFs,
So that I can process it for embedding generation.

**Acceptance Criteria:**

**Given** a PDF file uploaded to Firebase Storage
**When** the extraction service processes it
**Then** text is extracted from all pages using pdf-parse library
**And** page boundaries are preserved (text associated with page numbers)
**And** the extracted text structure contains:
  - Total page count
  - Array of { pageNumber, text } objects
**And** if extraction fails (corrupt PDF), document status is set to "error" with message
**And** the extraction handles PDFs with:
  - Standard text content
  - Multiple pages
  - Mixed formatting

**Given** a text-paste document (no PDF)
**When** extraction runs
**Then** the text is used directly with pageNumber: 1

---

### Story 3.5: Implement Text Chunking Service

As the system,
I want to split document text into semantic chunks,
So that I can generate embeddings for retrieval.

**Acceptance Criteria:**

**Given** extracted text from a document
**When** the chunking service processes it
**Then** text is split using LangChain RecursiveCharacterTextSplitter with:
  - chunkSize: 1000 characters
  - chunkOverlap: 200 characters
  - separators: ["\n\n", "\n", ". ", " ", ""]
**And** each chunk preserves metadata:
  - pageNumber (from which page the chunk originated)
  - chunkIndex (position within the document)
  - textPreview (first 200 characters for display)
**And** chunks crossing page boundaries are assigned to the starting page
**And** empty or whitespace-only chunks are filtered out

**Given** a document with 50 pages
**When** chunking completes
**Then** approximately 50-150 chunks are created (varies by content density)
**And** all chunks reference their source page number

---

### Story 3.6: Implement Embedding Generation Service

As the system,
I want to generate vector embeddings for each text chunk,
So that I can enable semantic search.

**Acceptance Criteria:**

**Given** an array of text chunks
**When** the embedding service processes them
**Then** embeddings are generated using Google's text-embedding-004 model
**And** each embedding is a 768-dimensional vector
**And** embeddings are generated in batches (max 100 per API call) to avoid rate limits
**And** if embedding generation fails for a chunk, it is retried 3 times with exponential backoff
**And** if all retries fail, the document status is set to "error"

**Given** 100 chunks to embed
**When** embedding completes successfully
**Then** 100 embedding vectors are returned with their metadata
**And** total processing time is logged for monitoring

---

### Story 3.7: Implement Vector Storage in Pinecone

As the system,
I want to store embeddings in Pinecone with proper metadata,
So that I can retrieve relevant chunks during queries.

**Acceptance Criteria:**

**Given** generated embeddings with metadata
**When** the vector service stores them in Pinecone
**Then** vectors are upserted to `brainvault-index` with:
  - id: `{documentId}_{chunkIndex}`
  - values: 768-dimensional embedding array
  - metadata: { userId, documentId, pageNumber, chunkIndex, textPreview }
**And** upserts are batched (max 100 vectors per API call)
**And** all vectors for a document are stored before marking complete

**Given** a document with 100 chunks
**When** storage completes
**Then** all 100 vectors are queryable in Pinecone
**And** vectors are isolated by userId metadata (cannot be retrieved by other users)

---

### Story 3.8: Implement Document Processing Status Tracking

As a user,
I want to see the processing status of my uploaded document,
So that I know when it's ready for querying.

**Acceptance Criteria:**

**Given** I uploaded a document
**When** processing is in progress
**Then** the UI shows "Processing..." with an animated indicator
**And** the document appears in my list with status badge "Processing"

**Given** a GET request to `/api/v1/documents/{documentId}/status`
**When** the document is processing
**Then** response returns: `{ status: "processing", progress: 50 }` (optional progress)

**Given** processing completes successfully
**When** I check the document status
**Then** status changes to "ready"
**And** the UI updates to show the document is ready for chat
**And** a subtle success animation plays

**Given** processing fails
**When** I check the document status
**Then** status shows "error" with message: "Unable to process this document"
**And** a retry option is available

---

### Story 3.9: Implement Upload Cancellation

As a user,
I want to cancel a document upload before it completes,
So that I can abort if I selected the wrong file.

**Acceptance Criteria:**

**Given** a document is being uploaded/processed
**When** I tap the "Cancel" button
**Then** a confirmation dialog appears: "Cancel upload?"
**And** if confirmed:
  - The upload request is cancelled
  - Any partial data in Storage/Firestore is cleaned up
  - The document is removed from my list
  - I return to the home screen
**And** if processing already completed, cancel is not available

---

## Epic 4: Document Management & Library

Enable users to view, organize, and manage their uploaded documents. Users can browse their document library, see metadata, select documents for chat, and delete unwanted documents.

### Story 4.1: Implement Document List Screen

As a user,
I want to see a list of all my uploaded documents,
So that I can browse and select documents to chat with.

**Acceptance Criteria:**

**Given** I am logged in and on the home screen
**When** the screen loads
**Then** my documents are fetched from `/api/v1/documents`
**And** documents are displayed as cards showing:
  - Document title/filename
  - Upload date (formatted: "Jan 5, 2026")
  - File size (formatted: "2.4 MB")
  - Status badge (Processing/Ready/Error)
**And** documents are sorted by newest first (reverse chronological)
**And** skeleton loaders appear while loading
**And** if I have no documents, an empty state is shown with prompt to upload

**Given** the API call fails
**When** the error occurs
**Then** an error message is shown with retry button

---

### Story 4.2: Implement Document List Caching

As a user,
I want my document list to load instantly from cache,
So that I see content immediately when opening the app.

**Acceptance Criteria:**

**Given** I previously loaded my document list
**When** I open the app or return to the home screen
**Then** cached documents are displayed immediately (< 500ms)
**And** a background refresh fetches latest data from API
**And** if new documents exist, the list updates smoothly
**And** cache is stored in SharedPreferences

**Given** I am offline
**When** I open the document list
**Then** cached documents are displayed
**And** a subtle banner shows "Offline - showing cached data"
**And** upload and chat features show "Requires internet connection"

---

### Story 4.3: Implement Pull-to-Refresh

As a user,
I want to pull down to refresh my document list,
So that I can see newly uploaded documents.

**Acceptance Criteria:**

**Given** I am on the document list screen
**When** I pull down on the list
**Then** a refresh indicator appears
**And** the document list is re-fetched from the API
**And** the list updates with any new or changed documents
**And** the refresh indicator disappears when complete

**Given** refresh fails due to network error
**When** the error occurs
**Then** a snackbar shows "Couldn't refresh. Please try again."
**And** the existing cached list remains visible

---

### Story 4.4: Implement Document Selection for Chat

As a user,
I want to tap a document to enter its chat interface,
So that I can ask questions about that document.

**Acceptance Criteria:**

**Given** I am on the document list
**When** I tap a document with status "Ready"
**Then** I navigate to the chat screen for that document
**And** the document title is shown in the app bar
**And** the chat history for that document is loaded (if any)

**Given** I tap a document with status "Processing"
**When** the tap occurs
**Then** a message appears: "This document is still processing. Please wait."
**And** I remain on the document list

**Given** I tap a document with status "Error"
**When** the tap occurs
**Then** a dialog appears with error details and options: "Retry" or "Delete"

---

### Story 4.5: Implement Document Deletion

As a user,
I want to delete documents I no longer need,
So that I can manage my knowledge vault.

**Acceptance Criteria:**

**Given** I am on the document list
**When** I long-press a document (or tap delete icon)
**Then** a confirmation dialog appears: "Delete [document name]? This cannot be undone."

**Given** I confirm deletion
**When** the delete request is sent
**Then** the document is removed from my list immediately (optimistic UI)
**And** a DELETE request is sent to `/api/v1/documents/{documentId}`
**And** the backend deletes:
  - Firestore document record
  - Firebase Storage file
  - All vectors in Pinecone with this documentId
  - All chat history for this document
**And** a snackbar confirms: "Document deleted"

**Given** deletion fails
**When** the error occurs
**Then** the document reappears in the list
**And** an error message is shown with retry option

---

### Story 4.6: Implement Document Metadata Display

As a user,
I want to see detailed information about a document,
So that I can understand what I've uploaded.

**Acceptance Criteria:**

**Given** I am viewing a document card
**When** I tap the info icon (or view details)
**Then** a bottom sheet shows:
  - Full document title
  - Original filename
  - File size
  - Page count (for PDFs)
  - Upload date and time
  - Processing duration (how long it took)
  - Number of chunks created
**And** I can close the bottom sheet to return to the list

---

## Epic 5: AI Chat & RAG-Powered Q&A

Enable users to have natural language conversations with their documents and receive accurate, cited answers.

### Story 5.1: Implement Chat Screen UI

As a user,
I want a chat interface for asking questions about my document,
So that I can have a conversation with my knowledge.

**Acceptance Criteria:**

**Given** I selected a document to chat with
**When** the chat screen loads
**Then** I see:
  - App bar with document title and back button
  - Message list area (empty or with history)
  - Text input field at bottom with send button
  - "New Chat" button to start fresh conversation
**And** the input field has placeholder: "Ask a question..."
**And** the keyboard opens when I tap the input field
**And** the send button is disabled when input is empty

**Given** I have previous chat history
**When** the screen loads
**Then** previous messages are displayed in chronological order
**And** the view scrolls to the most recent message

---

### Story 5.2: Implement Chat Message Bubbles

As a user,
I want my messages and AI responses displayed in chat bubbles,
So that I can easily follow the conversation.

**Acceptance Criteria:**

**Given** messages in the chat
**When** they are rendered
**Then** user messages appear in Primary Container color (#EADDFF) aligned right
**And** AI messages appear in Surface Variant color (#E7E0EC) aligned left
**And** each message shows:
  - Message text with proper line wrapping
  - Timestamp (e.g., "2:34 PM")
**And** AI messages include source citation chips below the text
**And** messages have rounded corners and proper padding
**And** long messages are fully readable (no truncation)

---

### Story 5.3: Implement Query Submission

As a user,
I want to send a question and see it appear in the chat,
So that I know my question was received.

**Acceptance Criteria:**

**Given** I typed a question in the input field
**When** I tap the send button (or press Enter)
**Then** the input field is cleared
**And** my question appears as a user message bubble immediately (optimistic UI)
**And** a "Thinking..." indicator appears below my message
**And** the view scrolls to show the new message
**And** the send button is disabled while awaiting response

**Given** I submit an empty message
**When** I tap send
**Then** nothing happens (button should be disabled)

---

### Story 5.4: Implement RAG Query API Endpoint

As the system,
I want an API endpoint to process user questions using RAG,
So that I can return accurate, cited answers.

**Acceptance Criteria:**

**Given** an authenticated user with a question
**When** POST request is made to `/api/v1/documents/{documentId}/chat`
**Then** the system:
  1. Embeds the user question using text-embedding-004
  2. Queries Pinecone with filters: userId AND documentId
  3. Retrieves top 3 most relevant chunks
  4. Builds context with page citations
  5. Sends to LLM with strict system prompt
  6. Returns structured response

**Response format:**
```json
{
  "answer": "The contract requires 30 days notice...",
  "sources": [
    { "pageNumber": 12, "snippet": "...30 days written notice..." },
    { "pageNumber": 15, "snippet": "...termination clause..." }
  ],
  "confidence": 0.92
}
```

**Given** no relevant chunks are found (similarity < 0.7)
**When** the query is processed
**Then** response returns:
```json
{
  "answer": "I don't have information about that in your document.",
  "sources": [],
  "confidence": 0
}
```

---

### Story 5.5: Implement Source Citation Display

As a user,
I want to see where the AI found its answer,
So that I can trust and verify the response.

**Acceptance Criteria:**

**Given** an AI response with sources
**When** the message is displayed
**Then** source citations appear as tappable chips below the answer
**And** each chip shows: "Source: Page X"
**And** chips use Tertiary Container color (#FFD8E4)
**And** multiple sources show as multiple chips

**Given** I tap a source citation chip
**When** the tap occurs
**Then** a bottom sheet appears showing:
  - "Source: Page X" header
  - The relevant text snippet from that page
  - Close button
**And** the snippet text is highlighted or emphasized

**Given** an AI response with no sources
**When** the message is displayed
**Then** no source chips are shown
**And** this indicates the AI couldn't find relevant information

---

### Story 5.6: Implement Streaming Response Display

As a user,
I want to see the AI response appear word-by-word,
So that I feel the response is being generated in real-time.

**Acceptance Criteria:**

**Given** the AI is generating a response
**When** the response streams from the backend
**Then** text appears incrementally in the AI message bubble
**And** the cursor/indicator shows more text is coming
**And** source citations appear after the full text is received
**And** the view auto-scrolls as text appears

**Given** streaming is not available (fallback)
**When** the full response is received
**Then** the "Thinking..." indicator is replaced with the complete response
**And** response appears with a subtle fade-in animation

---

### Story 5.7: Implement Hallucination Prevention

As a user,
I want the AI to admit when it doesn't know something,
So that I can trust it won't make things up.

**Acceptance Criteria:**

**Given** I ask a question not covered in my document
**When** the AI processes the query
**Then** it responds: "I don't have information about that in your document."
**And** no source citations are shown
**And** the response is helpful, not dismissive

**Given** I ask about something outside the document scope
**Example:** "What's the weather today?"
**When** the AI responds
**Then** it says: "I can only answer questions about your uploaded document."

**Given** retrieved chunks have low relevance scores (< 0.7)
**When** the AI would need to guess
**Then** it admits uncertainty rather than fabricating an answer

---

### Story 5.8: Implement Chat History Persistence

As a user,
I want my chat history saved per document,
So that I can continue conversations later.

**Acceptance Criteria:**

**Given** I have a conversation with a document
**When** I navigate away and return later
**Then** my previous messages and AI responses are loaded
**And** I can continue the conversation
**And** messages are in chronological order

**Given** chat history is stored
**When** saved to Firestore
**Then** each message includes:
  - role: "user" | "assistant"
  - content: message text
  - sources: array of { pageNumber, snippet }
  - timestamp: when sent
**And** messages are stored in `documents/{documentId}/chats/{chatId}`
**And** messages array is limited to last 100 messages (pagination for older)

---

### Story 5.9: Implement New Conversation

As a user,
I want to start a fresh conversation with a document,
So that I can explore different topics without prior context.

**Acceptance Criteria:**

**Given** I am in a chat with existing history
**When** I tap "New Chat" button
**Then** a confirmation dialog appears: "Start new conversation? Current chat will be saved."
**And** if confirmed:
  - Current chat is saved to history
  - Chat screen clears
  - I can ask new questions
  - A new chat session ID is generated

**Given** I start a new conversation
**When** I send a question
**Then** the AI does not reference previous conversation context
**And** only the current question and document chunks are used

---

### Story 5.10: Implement Chat Rate Limiting

As the system,
I want to limit chat queries per user,
So that I protect API costs and free tier limits.

**Acceptance Criteria:**

**Given** a user sends many queries quickly
**When** they exceed 10 queries per minute
**Then** a 429 response is returned: "Query limit reached. Please wait a moment."
**And** the UI shows: "You're asking too fast! Please wait 30 seconds."
**And** the send button is disabled with countdown timer

**Given** the rate limit window resets
**When** the user tries again
**Then** queries are allowed again
**And** the UI returns to normal

---

## Epic 6: Error Handling, Loading States & Polish

Ensure professional UX quality with comprehensive feedback, error handling, and visual polish throughout the app.

### Story 6.1: Implement Comprehensive Loading States

As a user,
I want clear visual feedback during all loading operations,
So that I know the app is working.

**Acceptance Criteria:**

**Given** any async operation is in progress
**When** loading occurs
**Then** appropriate loading UI is shown:
  - Document list: Skeleton loaders (card shapes)
  - Document upload: Progress indicator with percentage
  - Chat response: "Thinking..." with animated dots
  - Navigation: Subtle loading bar
**And** loading indicators match the brand style
**And** no screen ever appears "stuck" without feedback

**Given** loading takes longer than expected (> 5 seconds)
**When** the delay occurs
**Then** additional context is shown: "This is taking longer than usual..."
**And** user is not left wondering if app is frozen

---

### Story 6.2: Implement Error Message System

As a user,
I want helpful error messages when things go wrong,
So that I know what happened and what to do.

**Acceptance Criteria:**

**Given** any error occurs
**When** the error is displayed
**Then** the message is:
  - User-friendly (no technical jargon)
  - Specific (what went wrong)
  - Actionable (what to do next)
**And** error messages follow this format:
  - Network error: "Couldn't connect. Please check your internet and try again."
  - Upload failed: "Upload failed. Please try again or choose a different file."
  - Processing error: "We couldn't process this document. It may be corrupted."
  - Rate limit: "You're doing that too fast. Please wait a moment."

**Given** an error with a retry option
**When** I tap "Try Again"
**Then** the operation is retried
**And** if successful, error clears and success state shows

---

### Story 6.3: Implement Network Status Handling

As a user,
I want the app to handle network issues gracefully,
So that I don't lose my work or get confused.

**Acceptance Criteria:**

**Given** I lose network connection
**When** the disconnection is detected
**Then** a subtle banner appears: "You're offline"
**And** cached content remains visible
**And** actions requiring network show appropriate messages

**Given** I try to upload while offline
**When** the action fails
**Then** the message says: "Upload requires an internet connection"
**And** no retry loop occurs

**Given** network is restored
**When** reconnection is detected
**Then** the offline banner disappears
**And** pending operations can be retried
**And** document list refreshes automatically

---

### Story 6.4: Implement Material Design 3 Theme Polish

As a user,
I want a polished, modern visual experience,
So that the app feels professional and trustworthy.

**Acceptance Criteria:**

**Given** the app is running
**When** I use any screen
**Then** the following design standards are met:
  - Primary color: #6750A4 (Deep Purple)
  - Tertiary color: #7D5260 (Dusty Rose) for citations
  - Roboto font family throughout
  - 8dp spacing grid consistently applied
  - 48dp minimum touch targets
  - Proper elevation and shadows per MD3
**And** light mode and dark mode are both supported
**And** colors adapt correctly in dark mode
**And** all icons are from Material Icons set

---

### Story 6.5: Implement Micro-Animations & Transitions

As a user,
I want smooth animations and transitions,
So that the app feels responsive and polished.

**Acceptance Criteria:**

**Given** navigation between screens
**When** the transition occurs
**Then** a smooth slide or fade animation plays (< 300ms)

**Given** a document finishes processing
**When** the status updates
**Then** a subtle success checkmark animation plays

**Given** a message is sent in chat
**When** it appears in the list
**Then** it slides in smoothly from the bottom

**Given** an error snackbar appears
**When** it's shown
**Then** it slides up from the bottom and auto-dismisses after 4 seconds

**And** all animations are smooth (60fps)
**And** animations can be reduced/disabled for accessibility

---

### Story 6.6: Implement Accessibility Foundations

As a user with accessibility needs,
I want the app to be usable with assistive technologies,
So that I can access my knowledge vault.

**Acceptance Criteria:**

**Given** I use a screen reader
**When** navigating the app
**Then** all interactive elements have proper labels
**And** buttons announce their purpose
**And** images have alt text
**And** focus order is logical

**Given** I have vision impairment
**When** using the app
**Then** all text meets 4.5:1 contrast ratio
**And** text can be scaled up via system settings
**And** no information is conveyed by color alone

**Given** I have motor impairment
**When** using touch targets
**Then** all targets are at least 48x48dp
**And** there's adequate spacing between targets
