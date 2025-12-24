---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
inputDocuments:
  - "_bmad-output/prd.md"
  - "_bmad-output/ux-design-specification.md"
workflowType: 'architecture'
lastStep: 7
status: 'complete'
completedDate: '2025-12-21'
project_name: 'brainvault-rag-mobile'
user_name: 'Rusit'
date: '2025-12-21'
---

# Architecture Decision Document - BrainVault

**Author:** Rusit
**Date:** 2025-12-21
**Version:** 1.0

**Status:** Complete

---

## Executive Summary

This Architecture Decision Document defines the technical blueprint for **BrainVault**, a "Second Brain" mobile application that enables users to upload PDF documents and interact with their content through AI-powered natural language conversations using Retrieval-Augmented Generation (RAG).

### Architectural Vision

BrainVault follows a **three-tier architecture** optimized for a solo developer building a portfolio-ready application:

1. **Presentation Tier:** Flutter cross-platform mobile app with Material Design 3
2. **Application Tier:** Node.js/Express RESTful API with LangChain.js orchestration
3. **Data Tier:** Dual database pattern (Firestore for metadata, Pinecone for vectors)

### Key Architectural Decisions

| Decision | Choice | Rationale |
| ---------- | -------- | ----------- |
| Mobile Framework | Flutter | Single codebase, portfolio flexibility |
| Backend Runtime | Node.js + TypeScript | Strong async handling for AI operations |
| AI Orchestration | LangChain.js | Industry-standard, modular RAG pipeline |
| Vector Database | Pinecone | Managed service, generous free tier |
| Document Database | Firestore | Firebase ecosystem, real-time capable |
| Authentication | Firebase Auth | Rapid implementation, guest mode support |
| LLM Provider | Gemini (swappable) | Free tier, provider abstraction layer |

### Architecture Principles

1. **User Journeys Drive Technical Decisions** — Every component exists to serve a user need
2. **Boring Technology for Stability** — Proven patterns over cutting-edge experiments
3. **Design Simple, Scale Later** — Optimize for solo development velocity
4. **Provider Agnostic AI** — Abstract LLM providers for future flexibility
5. **Trust Through Transparency** — Source citations are non-negotiable

---

## 1. Project Context Analysis

### 1.1 Requirements Overview

**Functional Requirements Summary:**
BrainVault implements 41 functional requirements across 7 capability areas:

| Capability Area | FR Range | Count | MVP Priority |
| ----------------- | ---------- | ------- | -------------- |
| User Authentication | FR1-FR6 | 6 | P0 (Core) |
| Document Ingestion | FR7-FR16 | 10 | P0 (Core) |
| Document Management | FR17-FR20 | 4 | P0 (Core) |
| Chat & Query Interface | FR21-FR29 | 9 | P0 (Core) |
| Chat History & Persistence | FR30-FR34 | 5 | P0 (Core) |
| Error Handling | FR35-FR38 | 4 | P0 (Core) |
| AI Response Quality | FR39-FR41 | 3 | P0 (Core) |

**Non-Functional Requirements:**

| Requirement | Target | Priority |
| ------------- | -------- | ---------- |
| Query Response Time | < 5 seconds end-to-end | Critical |
| Document Upload Time | < 30 seconds for ≤5MB | Critical |
| PDF Text Extraction | < 10 seconds | High |
| Vector Embedding | < 15 seconds | High |
| App Cold Start | < 3 seconds | Medium |
| System Uptime | 99% availability | Medium |
| Upload Success Rate | 100% for valid files | Critical |

### 1.2 Scale & Complexity Assessment

**Project Classification:**

- **Complexity Level:** Medium
- **Primary Domain:** Mobile Full-Stack (Flutter + Node.js + AI)
- **Technical Type:** Cross-platform Mobile Application with RAG Backend

**Complexity Indicators:**

| Indicator | Level | Rationale |
| ----------- | ------- | ----------- |
| Real-time Features | Low | Polling-based status; no WebSockets |
| Multi-tenancy | None | Single-user knowledge bases for MVP |
| Regulatory Compliance | None | No HIPAA, PCI-DSS, COPPA requirements |
| Integration Complexity | Medium | 4+ external services to orchestrate |
| Data Volume | Low-Medium | Max 5MB PDFs, typical < 50 docs/user |
| User Interaction Complexity | Medium | Conversational AI interface |

### 1.3 Technical Constraints & Dependencies

**Hard Constraints:**

- PDF file size: Maximum 5MB (enforced)
- Free tier service limits (Pinecone, Gemini, Firebase)
- Single developer, 5-day development timeline
- Cross-platform mobile (iOS + Android from single codebase)

**External Dependencies:**

| Service | Purpose | Tier |
| --------- | --------- | ------ |
| Firebase Auth | User authentication | Free |
| Firebase Firestore | Document metadata storage | Free |
| Firebase Storage | PDF file storage | Free |
| Pinecone | Vector embeddings storage | Free (Starter) |
| Google Gemini API | LLM for response generation | Free tier |
| PDF parsing library | Text extraction | Open source |

### 1.4 Cross-Cutting Concerns

**Architectural Concerns Spanning Multiple Components:**

1. **Error Handling Strategy**
   - Consistent error types and messages across layers
   - Graceful degradation when services unavailable
   - User-friendly error messaging with recovery guidance

2. **Authentication & Authorization**
   - Firebase Auth token management
   - API request authentication
   - Guest session handling and conversion

3. **Async Processing & Status Tracking**
   - Document ingestion pipeline stages
   - Progress reporting to mobile client
   - Background task reliability

4. **Caching Strategy**
   - Document list offline availability
   - Chat history local persistence
   - Network request caching

5. **Source Citation Tracking**
   - Page numbers preserved through chunking
   - Citation metadata stored with embeddings
   - UI display of verifiable sources

6. **Observability**
   - Firebase Crashlytics for mobile errors
   - API logging for debugging
   - Performance monitoring for SLA compliance

---

## 2. Technology Stack & Starter Templates

### 2.1 Primary Technology Domains

BrainVault spans two primary technology domains:

| Domain | Technology | Purpose |
| -------- | ------------ | --------- |
| Mobile Application | Flutter 3.x (Dart) | Cross-platform iOS/Android client |
| Backend API | Node.js 20 LTS + Express + TypeScript | RESTful API + RAG pipeline |
| AI Orchestration | LangChain.js | Document processing + LLM integration |
| Vector Storage | Pinecone | Semantic search embeddings |
| Application Data | Firebase (Firestore + Auth + Storage) | User data, auth, file storage |

### 2.2 Mobile App Starter Evaluation

**Options Considered:**

| Starter | Verdict | Rationale |
| --------- | --------- | ----------- |
| `flutter create` (Official) | ✅ Selected | Maximum flexibility, official tooling |
| Very Good CLI | ⚠️ Considered | Enterprise patterns overkill for MVP |
| Stacked CLI | ❌ Rejected | Learning curve conflicts with 5-day timeline |
| Mason templates | ⚠️ Considered | Good but adds tooling complexity |

#### Selected Approach: Official Flutter + Manual Architecture

**Initialization Command:**

```bash
flutter create --org com.brainvault --project-name brainvault_app --platforms ios,android brainvault_app
```

**Post-Initialization Dependencies:**

```yaml
# pubspec.yaml - Core Dependencies
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  
  # Networking
  dio: ^5.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # UI Components
  file_picker: ^6.1.1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

**Architectural Decisions from Starter:**

- **Language:** Dart 3.x with null safety
- **State Management:** Riverpod (as specified in PRD)
- **UI Framework:** Material Design 3 (built-in)
- **Minimum Targets:** iOS 12.0+, Android API 23+

### 2.3 Backend API Starter Evaluation

**Options Considered:**

| Starter | Verdict | Rationale |
| --------- | --------- | ----------- |
| Express Generator | ❌ Rejected | No TypeScript, too minimal |
| NestJS | ❌ Rejected | Framework overhead for simple API |
| Fastify | ⚠️ Considered | Fast but less LangChain examples |
| Manual Express + TS | ✅ Selected | Full control, LangChain-friendly |

#### Selected Approach: Manual Express + TypeScript

**Initialization Commands:**

```bash
# Initialize project
mkdir brainvault-api && cd brainvault-api
npm init -y

# Core dependencies
npm install express cors helmet dotenv
npm install @types/express @types/cors @types/node typescript ts-node-dev

# Firebase & Pinecone
npm install firebase-admin @pinecone-database/pinecone

# LangChain & AI
npm install langchain @langchain/google-genai @langchain/community
npm install pdf-parse

# Utilities
npm install multer uuid zod
npm install @types/multer @types/uuid

# Development
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D prettier jest @types/jest ts-jest
```

**Architectural Decisions from Starter:**

- **Runtime:** Node.js 20 LTS
- **Language:** TypeScript 5.x (strict mode)
- **Framework:** Express 4.x (minimal, flexible)
- **Validation:** Zod (runtime type checking)
- **Testing:** Jest (unit + integration)

### 2.4 AI & Data Layer Stack

**LangChain.js Pipeline:**

```typescript
// Core LangChain dependencies
import { PDFLoader } from "langchain/document_loaders/fs/pdf";
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";
import { GoogleGenerativeAIEmbeddings } from "@langchain/google-genai";
import { PineconeStore } from "@langchain/pinecone";
import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
```

**Vector Database Configuration:**

- **Provider:** Pinecone (Starter/Free tier)
- **Index:** Single index with user namespaces
- **Dimensions:** 768 (Gemini embedding-001)
- **Metric:** Cosine similarity

**LLM Configuration:**

- **Primary:** Google Gemini 1.5 Flash (free tier)
- **Fallback:** Abstracted for Replicate/Llama swap
- **Temperature:** 0.1 (factual responses)
- **Max Tokens:** 1024 (adequate for answers)

### 2.5 Project Structure

**Mobile App Structure:**

```text
brainvault_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app/
│   │   ├── app.dart                 # MaterialApp configuration
│   │   └── router.dart              # Navigation routes
│   ├── core/
│   │   ├── constants/               # App constants, API URLs
│   │   ├── theme/                   # Material 3 theme configuration
│   │   ├── utils/                   # Helpers, extensions
│   │   └── widgets/                 # Shared widgets
│   ├── features/
│   │   ├── auth/                    # Authentication feature
│   │   │   ├── data/                # Repositories, data sources
│   │   │   ├── domain/              # Entities, use cases
│   │   │   └── presentation/        # Screens, widgets, providers
│   │   ├── documents/               # Document management feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── chat/                    # Chat/query feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── settings/                # Settings feature
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── services/
│       ├── api_service.dart         # Dio HTTP client
│       ├── storage_service.dart     # Local storage (Hive)
│       └── auth_service.dart        # Firebase Auth wrapper
├── assets/
│   ├── images/
│   └── fonts/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
└── pubspec.yaml
```

**Backend API Structure:**

```text
brainvault-api/
├── src/
│   ├── index.ts                     # Express app entry
│   ├── config/
│   │   ├── env.ts                   # Environment variables
│   │   ├── firebase.ts              # Firebase Admin init
│   │   └── pinecone.ts              # Pinecone client init
│   ├── middleware/
│   │   ├── auth.ts                  # Firebase token verification
│   │   ├── error.ts                 # Global error handler
│   │   └── upload.ts                # Multer file handling
│   ├── routes/
│   │   ├── auth.routes.ts           # Auth endpoints
│   │   ├── documents.routes.ts      # Document CRUD
│   │   └── chat.routes.ts           # Query endpoints
│   ├── services/
│   │   ├── ingestion.service.ts     # PDF → Vectors pipeline
│   │   ├── rag.service.ts           # Query → Response pipeline
│   │   ├── embedding.service.ts     # Vector embedding generation
│   │   └── llm.service.ts           # LLM provider abstraction
│   ├── models/
│   │   ├── document.model.ts        # Document schema
│   │   ├── message.model.ts         # Chat message schema
│   │   └── user.model.ts            # User schema
│   ├── utils/
│   │   ├── chunker.ts               # Text chunking logic
│   │   ├── citations.ts             # Page number extraction
│   │   └── validators.ts            # Zod schemas
│   └── types/
│       └── index.ts                 # TypeScript interfaces
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── .env.example
├── tsconfig.json
├── package.json
└── Dockerfile
```

---

## 3. Core Architectural Decisions

### 3.1 Decision Priority Analysis

**Critical Decisions (Must be resolved before implementation):**

- ✅ Data modeling and schema design
- ✅ Authentication flow and token management
- ✅ RAG pipeline architecture
- ✅ API contract design
- ✅ Error handling strategy

**Important Decisions (Shape architecture significantly):**

- ✅ Caching strategy for offline mode
- ✅ State management patterns
- ✅ LLM provider abstraction
- ✅ Deployment architecture

**Deferred Decisions (Post-MVP):**

- ⏭️ Multi-document querying architecture
- ⏭️ Push notification infrastructure
- ⏭️ Team/workspace multi-tenancy

### 3.2 Data Architecture Decisions

#### ADR-001: Dual Database Pattern

**Decision:** Use Firestore for application data and Pinecone for vector embeddings.

**Context:**

RAG applications require two distinct data patterns:

1. Document metadata, user profiles, chat history (relational/document data)
2. Vector embeddings for semantic search (specialized vector operations)

**Options Considered:**

| Option | Pros | Cons |
| -------- | ------ | ------ |
| Firestore + Pinecone (Selected) | Best-of-breed for each purpose, generous free tiers | Two services to manage |
| Supabase (PostgreSQL + pgvector) | Single service, SQL | Less mature vector support |
| MongoDB Atlas + Vector Search | Single vendor | Higher cost, newer feature |

**Decision:** Firestore + Pinecone

**Rationale:**

- Firebase ecosystem integration (Auth, Storage, Firestore)
- Pinecone is purpose-built for production vector search
- Both have generous free tiers matching MVP constraints
- Clear separation of concerns

**Consequences:**

- Must sync document lifecycle between both databases
- Delete operations require cleanup in both stores

#### ADR-002: Firestore Data Models

**Decision:** Denormalized document-centric design optimized for mobile queries.

**User Collection:** `/users/{userId}`

```typescript
interface User {
  id: string;                    // Firebase Auth UID
  email: string;
  displayName?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  isGuest: boolean;
  documentCount: number;         // Denormalized counter
  settings: {
    theme: 'light' | 'dark' | 'system';
  };
}
```

**Documents Collection:** `/users/{userId}/documents/{documentId}`

```typescript
interface Document {
  id: string;
  userId: string;
  name: string;                  // Original filename
  originalName: string;          // Display name
  storagePath: string;           // Firebase Storage path
  fileSize: number;              // Bytes
  pageCount: number;
  status: 'uploading' | 'processing' | 'ready' | 'error';
  processingProgress: number;    // 0-100
  processingStage: string;       // Current stage description
  errorMessage?: string;
  vectorNamespace: string;       // Pinecone namespace reference
  chunkCount: number;            // Number of vectors stored
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Chat Sessions Collection:** `/users/{userId}/documents/{documentId}/chats/{chatId}`

```typescript
interface ChatSession {
  id: string;
  documentId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  messageCount: number;          // Denormalized counter
}
```

**Messages Subcollection:** `/users/{userId}/documents/{documentId}/chats/{chatId}/messages/{messageId}`

```typescript
interface Message {
  id: string;
  chatId: string;
  role: 'user' | 'assistant';
  content: string;
  citations?: Citation[];
  createdAt: Timestamp;
  isError?: boolean;
  errorMessage?: string;
}

interface Citation {
  documentId: string;
  documentName: string;
  pageNumber: number;
  chunkText?: string;            // Optional: snippet of source text
}
```

#### ADR-003: Pinecone Index Structure

**Decision:** Single index with user-scoped namespaces.

**Index Configuration:**

```typescript
{
  name: "brainvault-index",
  dimension: 768,               // Gemini embedding-001 dimensions
  metric: "cosine",
  spec: {
    serverless: {
      cloud: "aws",
      region: "us-east-1"
    }
  }
}
```

**Namespace Strategy:**

- Each user gets namespace: `user_{userId}`
- Vectors include metadata for document filtering

**Vector Metadata Schema:**

```typescript
interface VectorMetadata {
  documentId: string;
  documentName: string;
  pageNumber: number;
  chunkIndex: number;
  text: string;                  // Original text for citation display
  userId: string;
}
```

**Query Pattern:**

```typescript
// Query within user's namespace, optionally filtered by document
const results = await index.namespace(`user_${userId}`).query({
  vector: queryEmbedding,
  topK: 3,
  filter: { documentId: { $eq: documentId } },
  includeMetadata: true
});
```

### 3.3 Authentication & Security Decisions

#### ADR-004: Firebase Authentication Strategy

**Decision:** Firebase Auth with email/password and anonymous guest mode.

**Authentication Flows:**

```text
┌─────────────────────────────────────────────────────────────┐
│ FLOW 1: Email/Password Registration                         │
│                                                             │
│ Mobile App → Firebase Auth → Create User → Firestore User  │
│           → Return Firebase ID Token → Store Securely      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ FLOW 2: Guest Login (Anonymous Auth)                        │
│                                                             │
│ Mobile App → Firebase Auth (Anonymous) → Create Temp User  │
│           → Limited Firestore Access → Upgrade Path Later  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ FLOW 3: Guest to Full Account Conversion                    │
│                                                             │
│ Guest User → Link Email/Password Credential                │
│           → Preserve Data → Update User Profile            │
└─────────────────────────────────────────────────────────────┘
```

**Token Management:**

- Firebase ID tokens stored in Flutter Secure Storage
- Tokens automatically refreshed by Firebase SDK
- API requests include `Authorization: Bearer {idToken}` header
- Backend validates tokens using Firebase Admin SDK

#### ADR-005: API Authentication Middleware

**Decision:** Firebase token verification with graceful error handling.

```typescript
// middleware/auth.ts
import { auth } from '../config/firebase';
import { Request, Response, NextFunction } from 'express';

export interface AuthenticatedRequest extends Request {
  user: {
    uid: string;
    email?: string;
    isAnonymous: boolean;
  };
}

export const authenticateToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'UNAUTHORIZED',
      message: 'Missing or invalid authorization header'
    });
  }

  const token = authHeader.split('Bearer ')[1];

  try {
    const decodedToken = await auth.verifyIdToken(token);
    (req as AuthenticatedRequest).user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      isAnonymous: decodedToken.firebase.sign_in_provider === 'anonymous'
    };
    next();
  } catch (error) {
    return res.status(401).json({
      error: 'INVALID_TOKEN',
      message: 'Token is invalid or expired'
    });
  }
};
```

#### ADR-006: Security Measures

**Decision:** Defense-in-depth security appropriate for portfolio MVP.

| Layer | Measure | Implementation |
| ------- | --------- | ---------------- |
| Transport | HTTPS only | Render auto-provisions TLS |
| API | Rate limiting | 100 requests/minute per user |
| API | Helmet middleware | Security headers |
| API | CORS | Whitelist mobile app origins |
| Input | Zod validation | All request bodies validated |
| Files | Type validation | PDF only, max 5MB |
| Data | User isolation | Firestore security rules |
| Secrets | Environment variables | Never in code |

**Firestore Security Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /documents/{documentId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      
        match /chats/{chatId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
      
          match /messages/{messageId} {
            allow read, write: if request.auth != null && request.auth.uid == userId;
          }
        }
      }
    }
  }
}
```

### 3.4 API Design Decisions

#### ADR-007: RESTful API Design

**Decision:** RESTful API with resource-oriented endpoints and consistent patterns.

**Base URL:** `https://api.brainvault.app/v1` (or Render URL for MVP)

**Endpoint Design:**

| Method | Endpoint | Description |
| -------- | ---------- | ------------- |
| POST | `/auth/verify` | Verify Firebase token, create/get user |
| GET | `/documents` | List user's documents |
| POST | `/documents` | Upload new document (multipart) |
| GET | `/documents/:id` | Get document details |
| DELETE | `/documents/:id` | Delete document and vectors |
| GET | `/documents/:id/status` | Get processing status |
| POST | `/documents/:id/chat` | Send query, get response |
| GET | `/documents/:id/chat/history` | Get chat history |
| DELETE | `/documents/:id/chat` | Clear chat history |

**Request/Response Patterns:**

```typescript
// Standard success response
interface ApiResponse<T> {
  success: true;
  data: T;
  meta?: {
    pagination?: { page: number; limit: number; total: number; };
  };
}
 
// Standard error response
interface ApiError {
  success: false;
  error: {
    code: string;           // Machine-readable error code
    message: string;        // Human-readable message
    details?: object;       // Additional context
  };
}
```

#### ADR-008: Chat/Query API Contract

**Decision:** Synchronous request-response for queries with streaming consideration for future.

**Query Request:**

```typescript
// POST /documents/:id/chat
interface ChatRequest {
  message: string;            // User's natural language question
  sessionId?: string;         // Optional: continue existing session
}
```

**Query Response:**

```typescript
interface ChatResponse {
  success: true;
  data: {
    sessionId: string;
    message: {
      id: string;
      role: 'assistant';
      content: string;
      citations: Citation[];
      createdAt: string;
    };
  };
}

interface Citation {
  documentName: string;
  pageNumber: number;
  relevanceScore: number;
}
```

**Error Response (No Relevant Content):**

```typescript
{
  success: true,
  data: {
    sessionId: "...",
    message: {
      id: "...",
      role: "assistant",
      content: "I couldn't find relevant information about that in this document. This may be because the document doesn't cover this topic, or it uses different terminology. Try rephrasing your question or checking if this topic is in the document.",
      citations: [],
      createdAt: "..."
    }
  }
}
```

### 3.5 RAG Pipeline Architecture

#### ADR-009: Document Ingestion Pipeline

**Decision:** Multi-stage async pipeline with status tracking.

**Pipeline Stages:**

```text
┌───────────┐    ┌───────────┐    ┌───────────┐    ┌───────────┐
│  UPLOAD   │ → │  EXTRACT  │ → │   CHUNK   │ → │   EMBED   │
│           │    │           │    │           │    │           │
│ Validate  │    │ PDF Parse │    │ Split to  │    │ Generate  │
│ Store PDF │    │ Get Text  │    │ Semantic  │    │ Vectors   │
│ Create    │    │ Get Pages │    │ Chunks    │    │ Store in  │
│ Document  │    │           │    │           │    │ Pinecone  │
└───────────┘    └───────────┘    └───────────┘    └───────────┘
     ↓                ↓                ↓                ↓
   10%              30%              60%             100%
```

**Stage Implementation:**

```typescript
// services/ingestion.service.ts
export class IngestionService {
  async processDocument(documentId: string, filePath: string): Promise<void> {
    try {
      // Stage 1: Extract text
      await this.updateStatus(documentId, 'processing', 10, 'Extracting text...');
      const { text, pageCount } = await this.extractText(filePath);
      
      // Stage 2: Chunk text
      await this.updateStatus(documentId, 'processing', 30, 'Creating knowledge base...');
      const chunks = await this.chunkText(text);
      
      // Stage 3: Generate embeddings
      await this.updateStatus(documentId, 'processing', 60, 'Generating embeddings...');
      const embeddings = await this.generateEmbeddings(chunks);
      
      // Stage 4: Store in Pinecone
      await this.updateStatus(documentId, 'processing', 80, 'Storing vectors...');
      await this.storeVectors(documentId, embeddings, chunks);
      
      // Complete
      await this.updateStatus(documentId, 'ready', 100, 'Ready to chat!');
    } catch (error) {
      await this.updateStatus(documentId, 'error', 0, error.message);
      throw error;
    }
  }
}
```

#### ADR-010: Text Chunking Strategy

**Decision:** Recursive character splitter with page number preservation.

**Chunking Configuration:**

```typescript
const splitter = new RecursiveCharacterTextSplitter({
  chunkSize: 1000,           // Characters per chunk
  chunkOverlap: 200,         // Overlap for context continuity
  separators: ['\n\n', '\n', '. ', ' ', ''], // Priority order
});
```

**Page Number Preservation:**

```typescript
interface ChunkWithMetadata {
  text: string;
  pageNumber: number;
  chunkIndex: number;
  startOffset: number;
  endOffset: number;
}

// Track page boundaries during extraction
// Assign page numbers to chunks based on offset positions
```

**Rationale:**

- 1000 characters ≈ 200 words (optimal for embedding models)
- 200 character overlap prevents context loss at boundaries
- Recursive splitting preserves semantic units (paragraphs > sentences > words)

#### ADR-011: Query Pipeline Architecture

**Decision:** Three-stage retrieval with grounded generation.

**Query Flow:**

```text
┌──────────────────────────────────────────────────────────────┐
│ Stage 1: RETRIEVE                                            │
│                                                              │
│ User Query → Embed Query → Vector Search → Top 3 Chunks     │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Stage 2: AUGMENT                                             │
│                                                              │
│ System Prompt + Retrieved Context + User Query → LLM Prompt │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Stage 3: GENERATE                                            │
│                                                              │
│ LLM Prompt → Gemini API → Response + Citation Extraction    │
└──────────────────────────────────────────────────────────────┘
```

**System Prompt (Critical for Grounding):**

```typescript
const SYSTEM_PROMPT = `You are BrainVault, an AI assistant that answers questions ONLY based on the provided document context.

STRICT RULES:
1. ONLY use information from the provided context to answer
2. If the context doesn't contain relevant information, say "I couldn't find relevant information about that in this document"
3. NEVER make up or infer information not explicitly in the context
4. Always cite your sources using the format [Page X]
5. If multiple pages are relevant, cite all of them
6. Keep answers concise but complete
7. If asked about topics not in the document, acknowledge the limitation

CONTEXT FROM DOCUMENT:
{context}

USER QUESTION: {question}

Provide a helpful, accurate answer based ONLY on the context above.`;
```

#### ADR-012: LLM Provider Abstraction

**Decision:** Abstract LLM calls behind interface for provider swapping.

```typescript
// services/llm.service.ts
export interface LLMProvider {
  generateResponse(prompt: string, options?: LLMOptions): Promise<string>;
  generateEmbedding(text: string): Promise<number[]>;
}

export interface LLMOptions {
  temperature?: number;
  maxTokens?: number;
}

// Gemini implementation
export class GeminiProvider implements LLMProvider {
  private model: ChatGoogleGenerativeAI;
  private embeddings: GoogleGenerativeAIEmbeddings;

  constructor() {
    this.model = new ChatGoogleGenerativeAI({
      modelName: "gemini-1.5-flash",
      temperature: 0.1,
      maxOutputTokens: 1024,
    });
    this.embeddings = new GoogleGenerativeAIEmbeddings({
      modelName: "embedding-001",
    });
  }

  async generateResponse(prompt: string): Promise<string> {
    const response = await this.model.invoke(prompt);
    return response.content as string;
  }

  async generateEmbedding(text: string): Promise<number[]> {
    return this.embeddings.embedQuery(text);
  }
}

// Factory for provider selection
export function createLLMProvider(): LLMProvider {
  const provider = process.env.LLM_PROVIDER || 'gemini';
  
  switch (provider) {
    case 'gemini':
      return new GeminiProvider();
    case 'replicate':
      return new ReplicateProvider(); // Future implementation
    default:
      return new GeminiProvider();
  }
}
```

### 3.6 Frontend Architecture Decisions

#### ADR-013: State Management with Riverpod

**Decision:** Riverpod with code generation for type-safe state management.

**Provider Categories:**

```dart
// Auth State - Global
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() => const AsyncValue.loading();
  
  Future<void> signIn(String email, String password) async { ... }
  Future<void> signOut() async { ... }
}

// Document State - User-scoped
@riverpod
Future<List<Document>> documents(DocumentsRef ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref.watch(documentRepositoryProvider).getDocuments(user.uid);
}

// Chat State - Document-scoped
@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  AsyncValue<List<Message>> build(String documentId) => const AsyncValue.loading();
  
  Future<void> sendMessage(String content) async { ... }
}
```

**Provider Scope Hierarchy:**

```text
ProviderScope (app-wide)
├── authProvider (user session)
├── documentsProvider (user's documents)
└── chatNotifierProvider(docId) (per-document chat)
```

#### ADR-014: Navigation Strategy

**Decision:** GoRouter for declarative, type-safe navigation.

```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider) != null;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    
    if (!isLoggedIn && !isAuthRoute) return '/auth/welcome';
    if (isLoggedIn && isAuthRoute) return '/documents';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/documents',
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/documents',
          builder: (context, state) => const DocumentsScreen(),
        ),
        GoRoute(
          path: '/documents/:id/chat',
          builder: (context, state) => ChatScreen(
            documentId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) => const SignupScreen(),
    ),
  ],
);
```

#### ADR-015: Offline Caching Strategy

**Decision:** Hive for local persistence with selective caching.

**Cache Categories:**

| Data | Cache Strategy | TTL |
| ------ | --------------- | ----- |
| Document List | Cache-first, sync on open | Until sync |
| Document Metadata | Cache-first | Until sync |
| Chat History | Cache-first, append-only | Permanent |
| User Preferences | Local-only | Permanent |
| Auth Token | Secure storage | Until expiry |

**Implementation:**

```dart
// services/storage_service.dart
@riverpod
class StorageService extends _$StorageService {
  late Box<Document> _documentsBox;
  late Box<Message> _messagesBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DocumentAdapter());
    Hive.registerAdapter(MessageAdapter());
    _documentsBox = await Hive.openBox('documents');
    _messagesBox = await Hive.openBox('messages');
  }
  
  // Cache-first pattern
  Future<List<Document>> getDocuments(String userId) async {
    // Return cached immediately
    final cached = _documentsBox.values.toList();
    
    // Sync in background if online
    if (await hasConnection()) {
      final fresh = await _api.getDocuments();
      await _documentsBox.clear();
      await _documentsBox.addAll(fresh);
      return fresh;
    }
    
    return cached;
  }
}
```

### 3.7 Infrastructure & Deployment Decisions

#### ADR-016: Deployment Architecture

**Decision:** Render for backend, Firebase for services, manual mobile builds.

**Infrastructure Diagram:**

```text
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                  │
│                                                                 │
│    ┌──────────┐                         ┌──────────┐           │
│    │   iOS    │                         │ Android  │           │
│    │   App    │                         │   App    │           │
│    └────┬─────┘                         └────┬─────┘           │
│         │                                    │                  │
│         └──────────────┬────────────────────┘                  │
│                        ↓                                        │
└────────────────────────┼────────────────────────────────────────┘
                         │
                    HTTPS│
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                      RENDER                                      │
│                                                                 │
│    ┌─────────────────────────────────────────────────────┐     │
│    │              Node.js API Service                     │     │
│    │                                                      │     │
│    │  • Express REST API                                  │     │
│    │  • LangChain.js RAG Pipeline                        │     │
│    │  • Firebase Admin SDK                               │     │
│    │  • Pinecone Client                                  │     │
│    │  • Gemini API Client                                │     │
│    └─────────────────────────────────────────────────────┘     │
│                                                                 │
└───────────────────────────┼─────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ↓                 ↓                 ↓
┌──────────────────┐ ┌─────────────┐ ┌──────────────────┐
│     FIREBASE     │ │   PINECONE  │ │  GOOGLE GEMINI   │
│                  │ │             │ │                  │
│ • Authentication │ │ • Vector    │ │ • Embeddings     │
│ • Firestore DB   │ │   Storage   │ │ • Chat LLM       │
│ • Cloud Storage  │ │ • Semantic  │ │                  │
│                  │ │   Search    │ │                  │
└──────────────────┘ └─────────────┘ └──────────────────┘
```

**Render Configuration:**

```yaml
# render.yaml
services:
  - type: web
    name: brainvault-api
    env: node
    plan: free
    buildCommand: npm install && npm run build
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: FIREBASE_PROJECT_ID
        sync: false
      - key: FIREBASE_PRIVATE_KEY
        sync: false
      - key: PINECONE_API_KEY
        sync: false
      - key: GEMINI_API_KEY
        sync: false
    healthCheckPath: /health
```

#### ADR-017: Environment Configuration

**Decision:** Environment variables with validation at startup.

**Environment Schema:**

```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.string().default('3000'),
  
  // Firebase
  FIREBASE_PROJECT_ID: z.string(),
  FIREBASE_CLIENT_EMAIL: z.string(),
  FIREBASE_PRIVATE_KEY: z.string(),
  
  // Pinecone
  PINECONE_API_KEY: z.string(),
  PINECONE_INDEX_NAME: z.string().default('brainvault-index'),
  
  // Gemini
  GEMINI_API_KEY: z.string(),
  
  // Optional
  LLM_PROVIDER: z.enum(['gemini', 'replicate']).default('gemini'),
  RATE_LIMIT_MAX: z.string().default('100'),
});

export const env = envSchema.parse(process.env);
```

**Mobile Configuration:**

```dart
// lib/core/constants/env.dart
class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );
  
  // Firebase config from google-services.json / GoogleService-Info.plist
}
```

#### ADR-018: Error Handling & Monitoring

**Decision:** Structured error handling with Firebase Crashlytics.

**Error Taxonomy:**

```typescript
enum ErrorCode {
  // Client errors (4xx)
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  FILE_TOO_LARGE = 'FILE_TOO_LARGE',
  INVALID_FILE_TYPE = 'INVALID_FILE_TYPE',
  
  // Server errors (5xx)
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE = 'SERVICE_UNAVAILABLE',
  
  // AI/RAG errors
  EMBEDDING_FAILED = 'EMBEDDING_FAILED',
  LLM_UNAVAILABLE = 'LLM_UNAVAILABLE',
  NO_RELEVANT_CONTENT = 'NO_RELEVANT_CONTENT',
  
  // External service errors
  FIREBASE_ERROR = 'FIREBASE_ERROR',
  PINECONE_ERROR = 'PINECONE_ERROR',
  GEMINI_ERROR = 'GEMINI_ERROR',
}
```

**Global Error Handler:**

```typescript
// middleware/error.ts
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err);
  
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
      },
    });
  }
  
  // Unknown errors
  return res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
  });
};
```

### 3.8 Decision Impact Summary

**Implementation Sequence:**

1. Firebase project setup (Auth, Firestore, Storage)
2. Pinecone index creation
3. Backend API scaffolding with middleware
4. Document upload and ingestion pipeline
5. RAG query pipeline
6. Mobile app foundation with auth
7. Document list and upload UI
8. Chat interface
9. Polish and demo recording

**Cross-Component Dependencies:**

| Component | Depends On |
| ----------- | ------------ |
| Mobile Auth | Firebase Auth, API verify endpoint |
| Document Upload | Firebase Storage, API upload endpoint |
| Processing Status | Firestore listeners |
| Chat Interface | RAG pipeline, API chat endpoint |
| Offline Cache | Hive, Firestore sync |
| Source Citations | Pinecone metadata, chunk storage |

---

## 4. Implementation Patterns & Consistency Rules

This section defines patterns that ensure all code (whether written by AI agents or developers) is consistent, compatible, and maintainable.

### 4.1 Naming Conventions

#### Database/Firestore Naming

| Element | Convention | Example |
| --------- | ------------ | --------- |
| Collections | lowercase plural | `users`, `documents`, `messages` |
| Document fields | camelCase | `userId`, `createdAt`, `pageCount` |
| Nested objects | camelCase | `settings.themeMode` |
| Timestamps | Firestore Timestamp | `createdAt: Timestamp` |
| Boolean fields | is/has prefix | `isGuest`, `hasError` |

```typescript
// ✅ CORRECT
{
  userId: "abc123",
  documentName: "Contract.pdf",
  isProcessing: false,
  createdAt: Timestamp.now()
}

// ❌ WRONG
{
  user_id: "abc123",
  DocumentName: "Contract.pdf",
  processing: false,
  created_at: "2025-12-21"
}
```

#### API Naming

| Element | Convention | Example |
| --------- | ------------ | --------- |
| Endpoints | lowercase plural, kebab-case | `/documents`, `/chat-sessions` |
| Route parameters | `:id` format | `/documents/:documentId` |
| Query parameters | camelCase | `?pageSize=10&sortBy=createdAt` |
| Request body | camelCase JSON | `{ "sessionId": "..." }` |
| Response body | camelCase JSON | `{ "documentId": "..." }` |

```typescript
// ✅ CORRECT
GET /v1/documents/:documentId/chat/history?pageSize=20

// ❌ WRONG
GET /v1/Document/:id/Chat_History?page_size=20
```

#### Flutter/Dart Naming

| Element | Convention | Example |
| --------- | ------------ | --------- |
| Files | snake_case | `document_card.dart`, `auth_service.dart` |
| Classes | PascalCase | `DocumentCard`, `AuthService` |
| Variables | camelCase | `documentList`, `isLoading` |
| Constants | camelCase or SCREAMING_SNAKE | `apiBaseUrl`, `MAX_FILE_SIZE` |
| Private members | underscore prefix | `_authState`, `_handleSubmit` |
| Providers | camelCase + Provider suffix | `documentsProvider`, `authStateProvider` |

```dart
// ✅ CORRECT
class DocumentCard extends ConsumerWidget {
  final Document document;
  final VoidCallback onTap;
  
  const DocumentCard({
    required this.document,
    required this.onTap,
    super.key,
  });
}

// ❌ WRONG
class document_card extends StatelessWidget {
  final Document Document;
  void OnTap() {}
}
```

#### Node.js/TypeScript Naming

| Element | Convention | Example |
| --------- | ------------ | --------- |
| Files | kebab-case | `auth.routes.ts`, `ingestion.service.ts` |
| Classes | PascalCase | `IngestionService`, `DocumentModel` |
| Functions | camelCase | `processDocument`, `generateEmbeddings` |
| Interfaces | PascalCase, no I prefix | `Document`, `ChatRequest` |
| Types | PascalCase | `DocumentStatus`, `ErrorCode` |
| Constants | SCREAMING_SNAKE | `MAX_FILE_SIZE`, `DEFAULT_CHUNK_SIZE` |
| Environment vars | SCREAMING_SNAKE | `FIREBASE_PROJECT_ID` |

```typescript
// ✅ CORRECT
interface Document {
  id: string;
  userId: string;
  createdAt: Date;
}

export class IngestionService {
  async processDocument(documentId: string): Promise<void> {}
}

// ❌ WRONG
interface IDocument {
  ID: string;
  user_id: string;
  CreatedAt: Date;
}

export class ingestion_service {
  async Process_Document(DocumentId: string): Promise<void> {}
}
```

### 4.2 Project Structure Patterns

#### Feature-Based Organization

Both mobile and backend use feature-based organization:

```text
# Pattern: features/{feature-name}/{layer}/
# Layers: data, domain, presentation (mobile) OR routes, services, models (backend)

# ✅ CORRECT - Feature-based
features/
  auth/
    data/
    domain/
    presentation/
  documents/
    data/
    domain/
    presentation/

# ❌ WRONG - Type-based
screens/
  login_screen.dart
  documents_screen.dart
services/
  auth_service.dart
  document_service.dart
models/
  user.dart
  document.dart
```

#### Test Co-location Pattern

Tests are organized parallel to source, not co-located:

```text
# ✅ CORRECT - Parallel test directories
lib/
  features/auth/
test/
  features/auth/

src/
  services/ingestion.service.ts
tests/
  services/ingestion.service.test.ts

# ❌ WRONG - Co-located tests
lib/
  features/auth/
    auth_service.dart
    auth_service.test.dart  # NO
```

#### Shared Code Location

| Code Type | Mobile Location | Backend Location |
| ----------- | ----------------- | ------------------ |
| Shared widgets | `lib/core/widgets/` | N/A |
| Theme/styling | `lib/core/theme/` | N/A |
| Utilities | `lib/core/utils/` | `src/utils/` |
| Constants | `lib/core/constants/` | `src/config/` |
| Types/Models | `lib/features/*/domain/` | `src/types/` |
| Services | `lib/services/` | `src/services/` |

### 4.3 API Contract Patterns

#### Request/Response Wrapper

**ALL API responses MUST use this wrapper:**

```typescript
// Success response
{
  "success": true,
  "data": { /* actual response data */ },
  "meta": { /* optional pagination, etc. */ }
}

// Error response
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { /* optional additional info */ }
  }
}
```

**Mobile client MUST parse using this pattern:**

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final ApiMeta? meta;
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
    );
  }
}
```

#### HTTP Status Code Usage

| Status | When to Use | Error Code |
| -------- | ------------- | ------------ |
| 200 | Successful GET, PUT, PATCH | N/A |
| 201 | Successful POST (created) | N/A |
| 204 | Successful DELETE (no content) | N/A |
| 400 | Validation error | `VALIDATION_ERROR` |
| 401 | Missing/invalid auth token | `UNAUTHORIZED` |
| 403 | Valid token, no permission | `FORBIDDEN` |
| 404 | Resource not found | `NOT_FOUND` |
| 413 | File too large | `FILE_TOO_LARGE` |
| 415 | Invalid file type | `INVALID_FILE_TYPE` |
| 429 | Rate limit exceeded | `RATE_LIMITED` |
| 500 | Server error | `INTERNAL_ERROR` |
| 503 | External service down | `SERVICE_UNAVAILABLE` |

### 4.4 State Management Patterns

#### Riverpod Provider Patterns

```dart
// Pattern 1: Simple async data
@riverpod
Future<List<Document>> documents(DocumentsRef ref) async {
  return ref.watch(documentRepositoryProvider).getAll();
}

// Pattern 2: Notifier for complex state with actions
@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  AsyncValue<ChatState> build(String documentId) {
    return const AsyncValue.loading();
  }
  
  Future<void> sendMessage(String content) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _sendMessage(content));
  }
}

// Pattern 3: Keep alive for expensive computations
@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
}
```

#### State Update Pattern

**ALWAYS use immutable updates:**

```dart
// ✅ CORRECT - Immutable update
state = state.copyWith(
  messages: [...state.messages, newMessage],
  isLoading: false,
);

// ❌ WRONG - Mutation
state.messages.add(newMessage);
state.isLoading = false;
```

### 4.5 Error Handling Patterns

#### Mobile Error Handling

```dart
// Pattern: Use AsyncValue for all async operations
class DocumentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsProvider);
    
    return documentsAsync.when(
      loading: () => const DocumentListSkeleton(),
      error: (error, stack) => ErrorView(
        message: error.userMessage,
        onRetry: () => ref.invalidate(documentsProvider),
      ),
      data: (documents) => DocumentListView(documents: documents),
    );
  }
}
```

**Error Message Mapping:**

```dart
extension ErrorMessageExtension on Object {
  String get userMessage {
    if (this is DioException) {
      final error = this as DioException;
      final apiError = ApiError.tryParse(error.response?.data);
      if (apiError != null) return apiError.message;
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
```

#### Backend Error Handling

```typescript
// Pattern: Custom error class with consistent structure
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: object
  ) {
    super(message);
    this.name = 'AppError';
  }
  
  static badRequest(message: string, details?: object) {
    return new AppError(400, 'VALIDATION_ERROR', message, details);
  }
  
  static notFound(resource: string) {
    return new AppError(404, 'NOT_FOUND', `${resource} not found`);
  }
  
  static unauthorized(message = 'Unauthorized') {
    return new AppError(401, 'UNAUTHORIZED', message);
  }
}

// Usage in routes
router.get('/:id', async (req, res, next) => {
  try {
    const document = await documentService.getById(req.params.id);
    if (!document) {
      throw AppError.notFound('Document');
    }
    res.json({ success: true, data: document });
  } catch (error) {
    next(error); // Passed to global error handler
  }
});
```

### 4.6 Loading State Patterns

#### Mobile Loading States

##### Pattern: Skeleton Loaders for Initial Load

```dart
// ✅ CORRECT - Skeleton matching final layout
class DocumentListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: const DocumentCardSkeleton(),
      ),
    );
  }
}

// ❌ WRONG - Generic spinner for list
class DocumentListLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
```

##### Pattern: Button Loading State

```dart
// Submit button with loading state
ElevatedButton(
  onPressed: isLoading ? null : _handleSubmit,
  child: isLoading
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : const Text('Submit'),
)
```

#### Backend Processing Status

##### Pattern: Status Polling Endpoint

```typescript
// GET /documents/:id/status
interface ProcessingStatus {
  status: 'uploading' | 'processing' | 'ready' | 'error';
  progress: number;           // 0-100
  stage: string;              // Human-readable stage
  errorMessage?: string;
}

// Mobile polls every 2 seconds during processing
```

### 4.7 Date/Time Patterns

**ALL dates use ISO 8601 format in APIs:**

```typescript
// API responses
{
  "createdAt": "2025-12-21T10:30:00.000Z",
  "updatedAt": "2025-12-21T14:45:30.000Z"
}
```

**Firestore uses Timestamp:**

```typescript
import { Timestamp } from 'firebase-admin/firestore';

const doc = {
  createdAt: Timestamp.now(),
  updatedAt: Timestamp.now()
};
```

**Mobile parsing:**

```dart
DateTime.parse(json['createdAt'] as String);
```

### 4.8 Logging Patterns

#### Backend Logging

```typescript
// Pattern: Structured logging with context
import { logger } from './config/logger';

// Request logging (middleware)
logger.info('Request received', {
  method: req.method,
  path: req.path,
  userId: req.user?.uid,
});

// Error logging
logger.error('Document processing failed', {
  documentId,
  userId,
  error: error.message,
  stack: error.stack,
});

// Performance logging
logger.info('RAG query completed', {
  documentId,
  queryLength: query.length,
  responseTime: endTime - startTime,
  chunksRetrieved: chunks.length,
});
```

#### Mobile Logging

```dart
// Pattern: Debug logs removed in production
import 'package:flutter/foundation.dart';

void logDebug(String message, [Object? data]) {
  if (kDebugMode) {
    print('[DEBUG] $message ${data ?? ""}');
  }
}

// Crashlytics for production errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Document upload failed',
);
```

### 4.9 Enforcement Guidelines

**All AI Agents MUST:**

1. ✅ Use the naming conventions defined in section 4.1
2. ✅ Follow the project structure patterns in section 4.2
3. ✅ Use the API response wrapper for ALL endpoints
4. ✅ Handle errors using the defined patterns
5. ✅ Use skeleton loaders, not spinners, for list loading
6. ✅ Use ISO 8601 for all date/time in API responses
7. ✅ Log with structured context, not string concatenation

**Pattern Verification Checklist:**

- [ ] File names match convention (snake_case for Dart, kebab-case for TS)
- [ ] API responses use `{ success, data, error }` wrapper
- [ ] Riverpod providers use correct patterns
- [ ] Error messages are user-friendly
- [ ] Loading states use appropriate UI patterns
- [ ] Dates use ISO 8601 format in APIs

### 4.10 Anti-Patterns to Avoid

```dart
// ❌ ANTI-PATTERN: Generic error messages
catch (e) {
  showSnackBar('Error occurred');
}

// ✅ CORRECT: Specific, actionable messages
catch (e) {
  showSnackBar(e.userMessage);
}
```

```typescript
// ❌ ANTI-PATTERN: Inconsistent response format
res.json({ users: [...] });  // Some endpoints
res.json({ data: { users: [...] } });  // Other endpoints

// ✅ CORRECT: Always use wrapper
res.json({ success: true, data: { users: [...] } });
```

```dart
// ❌ ANTI-PATTERN: Mutating state
state.items.add(newItem);
notifyListeners();

// ✅ CORRECT: Immutable updates with Riverpod
state = state.copyWith(items: [...state.items, newItem]);
```

---

## 5. Complete Project Structure

### 5.1 Repository Structure

BrainVault uses a **monorepo structure** with two primary projects:

```text
brainvault-rag-mobile/
├── README.md                        # Project overview, setup instructions
├── .gitignore                       # Git ignore rules
├── LICENSE                          # License file
│
├── mobile/                          # Flutter mobile application
│   └── brainvault_app/
│       ├── README.md
│       ├── pubspec.yaml
│       ├── pubspec.lock
│       ├── analysis_options.yaml
│       ├── .gitignore
│       ├── android/                 # Android-specific configuration
│       │   ├── app/
│       │   │   ├── build.gradle
│       │   │   ├── google-services.json  # Firebase config (gitignored)
│       │   │   └── src/main/
│       │   │       └── AndroidManifest.xml
│       │   ├── build.gradle
│       │   └── settings.gradle
│       ├── ios/                     # iOS-specific configuration
│       │   ├── Runner/
│       │   │   ├── Info.plist
│       │   │   ├── GoogleService-Info.plist  # Firebase config (gitignored)
│       │   │   └── AppDelegate.swift
│       │   ├── Runner.xcodeproj/
│       │   └── Podfile
│       ├── lib/                     # Dart source code
│       │   ├── main.dart
│       │   ├── firebase_options.dart
│       │   ├── app/
│       │   │   ├── app.dart
│       │   │   ├── router.dart
│       │   │   └── providers.dart
│       │   ├── core/
│       │   │   ├── constants/
│       │   │   │   ├── api_constants.dart
│       │   │   │   ├── app_constants.dart
│       │   │   │   └── storage_keys.dart
│       │   │   ├── theme/
│       │   │   │   ├── app_theme.dart
│       │   │   │   ├── colors.dart
│       │   │   │   └── typography.dart
│       │   │   ├── utils/
│       │   │   │   ├── extensions.dart
│       │   │   │   ├── validators.dart
│       │   │   │   └── formatters.dart
│       │   │   └── widgets/
│       │   │       ├── app_button.dart
│       │   │       ├── app_text_field.dart
│       │   │       ├── error_view.dart
│       │   │       ├── loading_indicator.dart
│       │   │       └── skeleton_loader.dart
│       │   ├── features/
│       │   │   ├── auth/
│       │   │   │   ├── data/
│       │   │   │   │   ├── auth_repository.dart
│       │   │   │   │   └── auth_remote_data_source.dart
│       │   │   │   ├── domain/
│       │   │   │   │   ├── entities/
│       │   │   │   │   │   └── user.dart
│       │   │   │   │   └── repositories/
│       │   │   │   │       └── i_auth_repository.dart
│       │   │   │   └── presentation/
│       │   │   │       ├── providers/
│       │   │   │       │   └── auth_provider.dart
│       │   │   │       ├── screens/
│       │   │   │       │   ├── welcome_screen.dart
│       │   │   │       │   ├── login_screen.dart
│       │   │   │       │   ├── signup_screen.dart
│       │   │   │       │   └── password_reset_screen.dart
│       │   │   │       └── widgets/
│       │   │   │           └── auth_form.dart
│       │   │   ├── documents/
│       │   │   │   ├── data/
│       │   │   │   │   ├── documents_repository.dart
│       │   │   │   │   └── documents_remote_data_source.dart
│       │   │   │   ├── domain/
│       │   │   │   │   ├── entities/
│       │   │   │   │   │   └── document.dart
│       │   │   │   │   └── repositories/
│       │   │   │   │       └── i_documents_repository.dart
│       │   │   │   └── presentation/
│       │   │   │       ├── providers/
│       │   │   │       │   └── documents_provider.dart
│       │   │   │       ├── screens/
│       │   │   │       │   └── documents_screen.dart
│       │   │   │       └── widgets/
│       │   │   │           ├── document_card.dart
│       │   │   │           ├── document_card_skeleton.dart
│       │   │   │           ├── documents_empty_state.dart
│       │   │   │           └── upload_progress_dialog.dart
│       │   │   ├── chat/
│       │   │   │   ├── data/
│       │   │   │   │   ├── chat_repository.dart
│       │   │   │   │   └── chat_remote_data_source.dart
│       │   │   │   ├── domain/
│       │   │   │   │   ├── entities/
│       │   │   │   │   │   ├── message.dart
│       │   │   │   │   │   ├── citation.dart
│       │   │   │   │   │   └── chat_session.dart
│       │   │   │   │   └── repositories/
│       │   │   │   │       └── i_chat_repository.dart
│       │   │   │   └── presentation/
│       │   │   │       ├── providers/
│       │   │   │       │   └── chat_provider.dart
│       │   │   │       ├── screens/
│       │   │   │       │   └── chat_screen.dart
│       │   │   │       └── widgets/
│       │   │   │           ├── chat_message.dart
│       │   │   │           ├── chat_input_bar.dart
│       │   │   │           ├── source_citation_chip.dart
│       │   │   │           ├── typing_indicator.dart
│       │   │   │           └── chat_empty_state.dart
│       │   │   └── settings/
│       │   │       ├── data/
│       │   │       │   └── settings_repository.dart
│       │   │       ├── domain/
│       │   │       │   └── entities/
│       │   │       │       └── user_settings.dart
│       │   │       └── presentation/
│       │   │           ├── providers/
│       │   │           │   └── settings_provider.dart
│       │   │           ├── screens/
│       │   │           │   └── settings_screen.dart
│       │   │           └── widgets/
│       │   │               └── settings_tile.dart
│       │   └── services/
│       │       ├── api_service.dart
│       │       ├── storage_service.dart
│       │       └── connectivity_service.dart
│       ├── assets/
│       │   ├── images/
│       │   │   ├── logo.png
│       │   │   ├── empty_documents.svg
│       │   │   └── empty_chat.svg
│       │   └── fonts/
│       ├── test/
│       │   ├── unit/
│       │   │   ├── features/
│       │   │   │   ├── auth/
│       │   │   │   ├── documents/
│       │   │   │   └── chat/
│       │   │   └── services/
│       │   ├── widget/
│       │   │   ├── features/
│       │   │   │   ├── auth/
│       │   │   │   ├── documents/
│       │   │   │   └── chat/
│       │   │   └── core/
│       │   └── integration/
│       │       └── app_test.dart
│       └── build/                   # Generated (gitignored)
│
├── api/                             # Node.js backend API
│   └── brainvault-api/
│       ├── README.md
│       ├── package.json
│       ├── package-lock.json
│       ├── tsconfig.json
│       ├── .env.example
│       ├── .env                     # Local environment (gitignored)
│       ├── .gitignore
│       ├── .eslintrc.js
│       ├── .prettierrc
│       ├── Dockerfile
│       ├── render.yaml              # Render deployment config
│       ├── src/
│       │   ├── index.ts             # Application entry point
│       │   ├── app.ts               # Express app configuration
│       │   ├── config/
│       │   │   ├── env.ts           # Environment validation
│       │   │   ├── firebase.ts      # Firebase Admin initialization
│       │   │   ├── pinecone.ts      # Pinecone client initialization
│       │   │   └── logger.ts        # Winston logger configuration
│       │   ├── middleware/
│       │   │   ├── auth.ts          # Firebase token verification
│       │   │   ├── error.ts         # Global error handler
│       │   │   ├── upload.ts        # Multer file upload config
│       │   │   ├── rate-limit.ts    # Rate limiting middleware
│       │   │   └── validate.ts      # Zod validation middleware
│       │   ├── routes/
│       │   │   ├── index.ts         # Route aggregator
│       │   │   ├── health.routes.ts # Health check endpoint
│       │   │   ├── auth.routes.ts   # Auth verification endpoints
│       │   │   ├── documents.routes.ts  # Document CRUD endpoints
│       │   │   └── chat.routes.ts   # Chat/query endpoints
│       │   ├── services/
│       │   │   ├── ingestion.service.ts    # PDF processing pipeline
│       │   │   ├── rag.service.ts          # Query/response pipeline
│       │   │   ├── embedding.service.ts    # Vector embedding generation
│       │   │   ├── llm.service.ts          # LLM provider abstraction
│       │   │   ├── document.service.ts     # Document CRUD operations
│       │   │   └── user.service.ts         # User management
│       │   ├── models/
│       │   │   ├── document.model.ts
│       │   │   ├── message.model.ts
│       │   │   ├── user.model.ts
│       │   │   └── chat-session.model.ts
│       │   ├── utils/
│       │   │   ├── chunker.ts       # Text chunking utilities
│       │   │   ├── citations.ts     # Page number extraction
│       │   │   ├── file.ts          # File handling utilities
│       │   │   └── async.ts         # Async utilities
│       │   ├── validators/
│       │   │   ├── document.validator.ts
│       │   │   ├── chat.validator.ts
│       │   │   └── common.validator.ts
│       │   ├── types/
│       │   │   ├── index.ts
│       │   │   ├── api.types.ts
│       │   │   ├── document.types.ts
│       │   │   └── chat.types.ts
│       │   └── errors/
│       │       └── app-error.ts     # Custom error classes
│       ├── tests/
│       │   ├── unit/
│       │   │   ├── services/
│       │   │   │   ├── ingestion.service.test.ts
│       │   │   │   ├── rag.service.test.ts
│       │   │   │   └── embedding.service.test.ts
│       │   │   └── utils/
│       │   │       ├── chunker.test.ts
│       │   │       └── citations.test.ts
│       │   ├── integration/
│       │   │   ├── documents.test.ts
│       │   │   └── chat.test.ts
│       │   └── fixtures/
│       │       └── sample.pdf
│       ├── dist/                    # Compiled output (gitignored)
│       └── uploads/                 # Temp upload directory (gitignored)
│
├── docs/                            # Project documentation
│   ├── api/
│   │   └── endpoints.md
│   ├── architecture/
│   │   └── diagrams/
│   └── setup/
│       ├── firebase-setup.md
│       ├── pinecone-setup.md
│       └── local-development.md
│
└── scripts/                         # Development scripts
    ├── setup-firebase.sh
    └── seed-test-data.ts
```

### 5.2 Functional Requirements Mapping

#### Authentication Feature (FR1-FR6)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR1 | Create account (email/password) | `features/auth/presentation/screens/signup_screen.dart` | `routes/auth.routes.ts` |
| FR2 | Login (email/password) | `features/auth/presentation/screens/login_screen.dart` | `routes/auth.routes.ts` |
| FR3 | Logout | `features/auth/presentation/providers/auth_provider.dart` | Firebase SDK |
| FR4 | Guest access | `features/auth/presentation/screens/welcome_screen.dart` | Firebase Anonymous Auth |
| FR5 | Guest to full account | `features/auth/data/auth_repository.dart` | Firebase SDK |
| FR6 | Password reset | `features/auth/presentation/screens/password_reset_screen.dart` | Firebase SDK |

#### Document Ingestion Feature (FR7-FR16)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR7 | Upload PDF | `features/documents/presentation/widgets/` | `routes/documents.routes.ts` |
| FR8 | Upload progress | `features/documents/presentation/widgets/upload_progress_dialog.dart` | `services/ingestion.service.ts` |
| FR9 | Validate PDF | `features/documents/data/documents_repository.dart` | `middleware/upload.ts`, `validators/` |
| FR10 | Extract text | — | `services/ingestion.service.ts` |
| FR11 | Split text to chunks | — | `utils/chunker.ts` |
| FR12 | Generate embeddings | — | `services/embedding.service.ts` |
| FR13 | Store embeddings | — | `services/ingestion.service.ts`, `config/pinecone.ts` |
| FR14 | Store metadata | — | `services/document.service.ts` |
| FR15 | Processing complete notification | `features/documents/presentation/providers/documents_provider.dart` | Firestore listener |
| FR16 | Processing error messages | `features/documents/presentation/widgets/document_card.dart` | `errors/app-error.ts` |

#### Document Management Feature (FR17-FR20)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR17 | View document list | `features/documents/presentation/screens/documents_screen.dart` | `routes/documents.routes.ts` |
| FR18 | View document metadata | `features/documents/presentation/widgets/document_card.dart` | `routes/documents.routes.ts` |
| FR19 | Delete document | `features/documents/data/documents_repository.dart` | `routes/documents.routes.ts` |
| FR20 | Select document for chat | `features/documents/presentation/screens/documents_screen.dart` | — |

#### Chat & Query Feature (FR21-FR29)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR21 | Natural language input | `features/chat/presentation/widgets/chat_input_bar.dart` | — |
| FR22 | Send query | `features/chat/data/chat_repository.dart` | `routes/chat.routes.ts` |
| FR23 | Loading indicator | `features/chat/presentation/widgets/typing_indicator.dart` | — |
| FR24 | Retrieve relevant chunks | — | `services/rag.service.ts` |
| FR25 | Pass to LLM | — | `services/llm.service.ts` |
| FR26 | Display response | `features/chat/presentation/widgets/chat_message.dart` | — |
| FR27 | Source citations | `features/chat/presentation/widgets/source_citation_chip.dart` | `services/rag.service.ts` |
| FR28 | Follow-up questions | `features/chat/presentation/providers/chat_provider.dart` | `routes/chat.routes.ts` |
| FR29 | Conversation context | `features/chat/domain/entities/chat_session.dart` | `models/chat-session.model.ts` |

#### Chat History Feature (FR30-FR34)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR30 | Persist chat history | `services/storage_service.dart` | Firestore |
| FR31 | View previous chats | `features/chat/presentation/screens/chat_screen.dart` | `routes/chat.routes.ts` |
| FR32 | Continue previous chat | `features/chat/data/chat_repository.dart` | `routes/chat.routes.ts` |
| FR33 | Clear chat history | `features/chat/data/chat_repository.dart` | `routes/chat.routes.ts` |
| FR34 | Local caching | `services/storage_service.dart` (Hive) | — |

#### Error Handling Feature (FR35-FR38)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR35 | No relevant content guidance | `features/chat/presentation/widgets/chat_message.dart` | `services/rag.service.ts` |
| FR36 | Scanned PDF limitation | `features/documents/presentation/widgets/upload_progress_dialog.dart` | `services/ingestion.service.ts` |
| FR37 | Network error handling | `services/api_service.dart`, `core/widgets/error_view.dart` | `middleware/error.ts` |
| FR38 | Error messages for all failures | `core/utils/extensions.dart` (userMessage) | `errors/app-error.ts` |

#### AI Response Quality (FR39-FR41)

| FR | Description | Mobile Location | API Location |
| ---- | ------------- | ----------------- | -------------- |
| FR39 | Grounded responses only | — | `services/rag.service.ts` (system prompt) |
| FR40 | Indicate when info not found | — | `services/rag.service.ts` |
| FR41 | Honest "I don't know" | — | `services/llm.service.ts` |

### 5.3 Architectural Boundaries

#### API Boundary Definitions

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                              MOBILE APP                                  │
│                                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐ │
│  │    Auth     │   │  Documents  │   │    Chat     │   │  Settings   │ │
│  │   Feature   │   │   Feature   │   │   Feature   │   │   Feature   │ │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘ │
│         │                 │                 │                 │         │
│         └────────────────┬┴─────────────────┴────────────────┘         │
│                          │                                              │
│                   ┌──────┴──────┐                                       │
│                   │ API Service │                                       │
│                   │    (Dio)    │                                       │
│                   └──────┬──────┘                                       │
└──────────────────────────┼──────────────────────────────────────────────┘
                           │
                      HTTPS│REST
                           │
┌──────────────────────────┼──────────────────────────────────────────────┐
│                          ▼           BACKEND API                         │
│                   ┌──────────────┐                                       │
│                   │   Express    │                                       │
│                   │   Router     │                                       │
│                   └──────┬───────┘                                       │
│                          │                                               │
│      ┌───────────────────┼───────────────────┐                          │
│      │                   │                   │                          │
│      ▼                   ▼                   ▼                          │
│ ┌─────────┐        ┌──────────┐       ┌──────────┐                      │
│ │  Auth   │        │Documents │       │   Chat   │                      │
│ │ Routes  │        │  Routes  │       │  Routes  │                      │
│ └────┬────┘        └────┬─────┘       └────┬─────┘                      │
│      │                  │                  │                            │
│      ▼                  ▼                  ▼                            │
│ ┌─────────┐        ┌──────────┐       ┌──────────┐                      │
│ │  User   │        │Ingestion │       │   RAG    │                      │
│ │ Service │        │ Service  │       │ Service  │                      │
│ └────┬────┘        └────┬─────┘       └────┬─────┘                      │
│      │                  │                  │                            │
└──────┼──────────────────┼──────────────────┼────────────────────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Firebase   │  │   Firebase   │  │   Pinecone   │  │    Gemini    │
│     Auth     │  │   Firestore  │  │   Vector DB  │  │     LLM      │
│   + Storage  │  │              │  │              │  │              │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

#### Service Boundary Rules

| Boundary | Rule |
| ---------- | ------ |
| Mobile → API | HTTP REST only, Firebase ID token in Authorization header |
| API → Firebase | Firebase Admin SDK, service account credentials |
| API → Pinecone | Pinecone Node.js client, API key authentication |
| API → Gemini | LangChain Google GenAI, API key authentication |
| Feature → Feature (Mobile) | Via shared providers, no direct imports across features |
| Service → Service (API) | Direct method calls, dependency injection pattern |

#### Data Flow Boundaries

```text
DOCUMENT UPLOAD FLOW:
Mobile → API (multipart) → Firebase Storage → Ingestion Service
       → PDF Parse → Chunker → Embedding Service → Pinecone
       → Document Service → Firestore (metadata)
       → Mobile (status polling via Firestore listener)

QUERY FLOW:
Mobile → API (POST /chat) → RAG Service
       → Embedding Service (query embedding)
       → Pinecone (similarity search)
       → LLM Service (augmented prompt)
       → Gemini API (generate response)
       → RAG Service (extract citations)
       → API → Mobile (display response)
```

### 5.4 Integration Points

#### Firebase Integration

```typescript
// config/firebase.ts - Single initialization point
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

const app = initializeApp({
  credential: cert({
    projectId: env.FIREBASE_PROJECT_ID,
    clientEmail: env.FIREBASE_CLIENT_EMAIL,
    privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  }),
  storageBucket: `${env.FIREBASE_PROJECT_ID}.appspot.com`,
});

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
```

#### Pinecone Integration

```typescript
// config/pinecone.ts - Single initialization point
import { Pinecone } from '@pinecone-database/pinecone';

const pinecone = new Pinecone({
  apiKey: env.PINECONE_API_KEY,
});

export const getIndex = () => pinecone.index(env.PINECONE_INDEX_NAME);
```

#### LLM Provider Integration

```typescript
// services/llm.service.ts - Provider abstraction
export interface LLMProvider {
  generateResponse(prompt: string): Promise<string>;
  generateEmbedding(text: string): Promise<number[]>;
}

export const createLLMProvider = (): LLMProvider => {
  switch (env.LLM_PROVIDER) {
    case 'gemini':
      return new GeminiProvider();
    default:
      return new GeminiProvider();
  }
};
```

### 5.5 Configuration Files

#### Mobile Configuration

| File | Purpose |
| ------ | --------- |
| `pubspec.yaml` | Dart dependencies, assets, version |
| `analysis_options.yaml` | Linting rules |
| `firebase_options.dart` | FlutterFire CLI generated config |
| `google-services.json` | Android Firebase config |
| `GoogleService-Info.plist` | iOS Firebase config |

#### Backend Configuration

| File | Purpose |
| ------ | --------- |
| `package.json` | Node dependencies, scripts |
| `tsconfig.json` | TypeScript configuration |
| `.env.example` | Environment variable template |
| `.eslintrc.js` | ESLint rules |
| `.prettierrc` | Code formatting rules |
| `render.yaml` | Render deployment configuration |
| `Dockerfile` | Container build configuration |

### 5.6 Development Workflow

#### Local Development Setup

```bash
# 1. Clone repository
git clone <repo-url>
cd brainvault-rag-mobile

# 2. Backend setup
cd api/brainvault-api
npm install
cp .env.example .env
# Edit .env with Firebase, Pinecone, Gemini credentials
npm run dev

# 3. Mobile setup (separate terminal)
cd mobile/brainvault_app
flutter pub get
# Add Firebase config files
flutter run
```

#### Build & Deployment

```bash
# Backend - Deploy to Render
# Push to main branch triggers auto-deploy via render.yaml

# Mobile - Build APK
cd mobile/brainvault_app
flutter build apk --release

# Mobile - Build iOS (macOS only)
flutter build ios --release
```

---

## 6. Architecture Validation

### 6.1 Coherence Validation ✅

#### Decision Compatibility

| Decision Area | Components | Compatibility Status |
| -------------- | ------------ | --------------------- |
| Flutter + Firebase | Mobile app + Auth/DB/Storage | ✅ Native Flutter SDKs available |
| Node.js + LangChain.js | Backend + AI pipeline | ✅ LangChain.js is Node-native |
| Express + TypeScript | API framework + type safety | ✅ Excellent TypeScript support |
| Pinecone + Gemini | Vector DB + LLM | ✅ LangChain integrations available |
| Riverpod + GoRouter | State + Navigation | ✅ Well-documented integration patterns |
| Firestore + Hive | Remote DB + Local cache | ✅ Complementary purposes |

**Verdict:** All technology choices are compatible and have proven integration patterns.

#### Pattern Consistency

| Pattern Category | Consistency Check | Status |
| ----------------- | ------------------- | -------- |
| Naming conventions | Mobile (snake_case files) + API (kebab-case files) | ✅ Language-appropriate |
| API response format | Wrapper pattern defined and enforced | ✅ Consistent |
| Error handling | Both layers use structured errors | ✅ Aligned |
| State management | Riverpod patterns documented | ✅ Complete |
| Feature organization | Both mobile and API use feature-based | ✅ Consistent |

**Verdict:** Implementation patterns are internally consistent and language-appropriate.

#### Structure Alignment

| Structural Element | Architecture Support | Status |
| ------------------- | --------------------- | -------- |
| Feature-based organization | Supports scaling and isolation | ✅ |
| Service layer abstraction | Enables LLM provider swapping | ✅ |
| Repository pattern | Supports offline caching | ✅ |
| Middleware pipeline | Supports auth, validation, errors | ✅ |
| Test organization | Parallel to source structure | ✅ |

**Verdict:** Project structure fully supports all architectural decisions.

### 6.2 Requirements Coverage Validation ✅

#### Functional Requirements Coverage

| FR Range | Capability | Architectural Support | Coverage |
| ---------- | ----------- | ---------------------- | ---------- |
| FR1-FR6 | Authentication | Firebase Auth + API middleware | ✅ 100% |
| FR7-FR16 | Document Ingestion | Ingestion pipeline + Storage | ✅ 100% |
| FR17-FR20 | Document Management | CRUD routes + Firestore | ✅ 100% |
| FR21-FR29 | Chat & Query | RAG service + Chat routes | ✅ 100% |
| FR30-FR34 | Chat History | Firestore + Hive cache | ✅ 100% |
| FR35-FR38 | Error Handling | Error middleware + patterns | ✅ 100% |
| FR39-FR41 | AI Quality | System prompt + grounding | ✅ 100% |

##### Total: 41/41 Functional Requirements Covered (100%)

#### Non-Functional Requirements Coverage

| NFR | Target | Architectural Support | Status |
| ----- | -------- | ---------------------- | -------- |
| Query response | < 5s | Pinecone fast retrieval, Gemini Flash | ✅ Supported |
| Upload | < 30s for 5MB | Async processing, progress tracking | ✅ Supported |
| PDF extraction | < 10s | pdf-parse library, server processing | ✅ Supported |
| Embedding | < 15s | Batch processing with Gemini | ✅ Supported |
| App cold start | < 3s | Flutter optimizations, lazy loading | ✅ Supported |
| Uptime | 99% | Render auto-restart, error recovery | ✅ Supported |
| Upload success | 100% | Validation, error handling | ✅ Supported |

##### All Non-Functional Requirements Architecturally Supported

### 6.3 Implementation Readiness Validation ✅

#### Decision Completeness

| Decision Type | Documentation Level | Status |
| -------------- | --------------------- | -------- |
| Technology stack | Versions specified | ✅ Complete |
| Data models | Full schemas with types | ✅ Complete |
| API contracts | Endpoints + request/response | ✅ Complete |
| Authentication | Flows + token handling | ✅ Complete |
| RAG pipeline | Stage-by-stage definition | ✅ Complete |
| Error handling | Taxonomy + patterns | ✅ Complete |
| LLM abstraction | Interface + implementation | ✅ Complete |

#### Structure Completeness

| Structure Element | Completeness | Status |
| ------------------ | -------------- | -------- |
| Directory structure | All files mapped | ✅ Complete |
| Feature mapping | FR → File mapping | ✅ Complete |
| Integration points | Defined with code samples | ✅ Complete |
| Configuration files | All listed with purposes | ✅ Complete |

#### Pattern Completeness

| Pattern Category | Coverage | Status |
| ----------------- | ---------- | -------- |
| Naming conventions | All layers covered | ✅ Complete |
| API patterns | Request/response/errors | ✅ Complete |
| State patterns | Riverpod with examples | ✅ Complete |
| Error patterns | Mobile + Backend | ✅ Complete |
| Loading patterns | Skeleton + button states | ✅ Complete |
| Logging patterns | Structured with context | ✅ Complete |

### 6.4 Gap Analysis Results

#### No Critical Gaps Identified ✅

The architecture covers all required functionality for MVP.

#### Minor Enhancement Opportunities (Post-MVP)

| Area | Enhancement | Priority |
| ------ | ------------- | ---------- |
| Testing strategy | Add more specific test patterns | Low |
| Monitoring | Add APM integration guidance | Low |
| CI/CD | Add GitHub Actions workflow | Low |
| Documentation | Add API documentation tooling | Low |

### 6.5 Architecture Completeness Checklist

#### ✅ Requirements Analysis

- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (Medium)
- [x] Technical constraints identified (free tier limits, 5MB PDF, 5-day timeline)
- [x] Cross-cutting concerns mapped (error handling, auth, caching, citations)

#### ✅ Technology Stack

- [x] Mobile: Flutter 3.x + Riverpod + GoRouter
- [x] Backend: Node.js 20 + Express + TypeScript
- [x] AI: LangChain.js + Gemini + Pinecone
- [x] Data: Firebase (Auth + Firestore + Storage)
- [x] All versions specified and compatible

#### ✅ Architectural Decisions (18 ADRs)

- [x] ADR-001: Dual database pattern
- [x] ADR-002: Firestore data models
- [x] ADR-003: Pinecone index structure
- [x] ADR-004: Firebase authentication strategy
- [x] ADR-005: API authentication middleware
- [x] ADR-006: Security measures
- [x] ADR-007: RESTful API design
- [x] ADR-008: Chat/Query API contract
- [x] ADR-009: Document ingestion pipeline
- [x] ADR-010: Text chunking strategy
- [x] ADR-011: Query pipeline architecture
- [x] ADR-012: LLM provider abstraction
- [x] ADR-013: State management with Riverpod
- [x] ADR-014: Navigation strategy
- [x] ADR-015: Offline caching strategy
- [x] ADR-016: Deployment architecture
- [x] ADR-017: Environment configuration
- [x] ADR-018: Error handling & monitoring

#### ✅ Implementation Patterns

- [x] Naming conventions for all layers
- [x] Project structure patterns
- [x] API contract patterns
- [x] State management patterns
- [x] Error handling patterns
- [x] Loading state patterns
- [x] Date/time patterns
- [x] Logging patterns
- [x] Anti-patterns documented

#### ✅ Project Structure

- [x] Complete directory tree (mobile + API)
- [x] FR → File mapping complete
- [x] Component boundaries defined
- [x] Integration points documented
- [x] Configuration files listed

### 6.6 Architecture Readiness Assessment

#### Overall Status: ✅ READY FOR IMPLEMENTATION

##### Confidence Level: HIGH

Based on:

- 100% functional requirements coverage
- All NFRs architecturally supported
- 18 architectural decisions documented
- Complete project structure defined
- Comprehensive implementation patterns

#### Key Strengths

1. **RAG Pipeline Clarity** — Stage-by-stage pipeline definition with code examples
2. **LLM Abstraction** — Provider-agnostic design enables future flexibility
3. **Citation System** — End-to-end tracking from chunks to UI
4. **Error Handling** — Consistent patterns across all layers
5. **Offline Support** — Caching strategy for mobile reliability
6. **Portfolio Ready** — Clean architecture suitable for demo

#### Areas for Future Enhancement

1. **Multi-document querying** — Deferred to post-MVP
2. **Streaming responses** — Could improve perceived performance
3. **Push notifications** — For async processing updates
4. **Advanced analytics** — Query patterns and usage insights

---

## 7. Implementation Handoff

### 7.1 Implementation Priority Order

```text
Phase 1: Foundation
├── 1.1 Create monorepo structure
├── 1.2 Initialize Flutter project with dependencies
├── 1.3 Initialize Node.js/Express project with TypeScript
├── 1.4 Configure Firebase project (Auth + Firestore + Storage)
└── 1.5 Configure Pinecone index

Phase 2: Backend Core
├── 2.1 Implement environment configuration and validation
├── 2.2 Set up Firebase Admin SDK integration
├── 2.3 Implement authentication middleware
├── 2.4 Create document routes (upload, list, delete)
└── 2.5 Implement document ingestion pipeline

Phase 3: RAG Pipeline
├── 3.1 Implement PDF text extraction
├── 3.2 Implement text chunking with page tracking
├── 3.3 Implement embedding generation service
├── 3.4 Implement Pinecone storage
├── 3.5 Implement RAG query service
└── 3.6 Implement chat routes

Phase 4: Mobile App Core
├── 4.1 Set up app structure and routing
├── 4.2 Implement auth feature (login, signup, guest)
├── 4.3 Implement documents feature (list, upload, status)
└── 4.4 Implement local caching with Hive

Phase 5: Chat Experience
├── 5.1 Implement chat UI components
├── 5.2 Implement chat provider and repository
├── 5.3 Implement source citation display
└── 5.4 Implement chat history persistence

Phase 6: Polish & Demo
├── 6.1 Implement loading states and skeletons
├── 6.2 Implement error handling UI
├── 6.3 Final UI polish and theming
└── 6.4 Record 30-second demo video
```

### 7.2 AI Agent Implementation Guidelines

**When implementing this architecture, AI agents MUST:**

1. ✅ Follow all naming conventions exactly as documented in Section 4.1
2. ✅ Use the project structure defined in Section 5.1
3. ✅ Implement API responses using the wrapper pattern (Section 4.3)
4. ✅ Use Riverpod patterns exactly as shown (Section 4.4)
5. ✅ Follow error handling patterns (Section 4.5)
6. ✅ Use skeleton loaders for list loading states (Section 4.6)
7. ✅ Use ISO 8601 dates in all API responses (Section 4.7)
8. ✅ Reference ADRs when making implementation decisions
9. ✅ Respect feature boundaries — no cross-feature imports
10. ✅ Track source citations from chunk storage to UI display

**When in doubt:**

- Check this architecture document first
- Follow the patterns section for consistency rules
- Use the FR → File mapping to locate implementation targets
- Ask for clarification rather than assuming

### 7.3 First Implementation Step

```bash
# Step 1: Create the monorepo structure
mkdir brainvault-rag-mobile
cd brainvault-rag-mobile

# Step 2: Initialize Flutter project
mkdir -p mobile
cd mobile
flutter create --org com.brainvault --project-name brainvault_app --platforms ios,android brainvault_app

# Step 3: Initialize API project
cd ..
mkdir -p api/brainvault-api
cd api/brainvault-api
npm init -y
npm install express cors helmet dotenv typescript ts-node-dev
npm install @types/express @types/cors @types/node
npx tsc --init
```

### 7.4 Success Criteria Reminder

From PRD — the MVP succeeds when:

1. ✅ A user can upload a PDF and ask it questions
2. ✅ The AI returns accurate answers with source citations
3. ✅ The experience is smooth enough to record a 30-second demo video
4. ✅ The codebase is clean enough to reuse for client projects

**This architecture fully supports all success criteria.**

---

## Appendix A: Quick Reference

### API Endpoints Summary

| Method | Endpoint | Auth | Description |
| -------- | ---------- | ------ | ------------- |
| GET | `/health` | No | Health check |
| POST | `/v1/auth/verify` | Yes | Verify token, create/get user |
| GET | `/v1/documents` | Yes | List user's documents |
| POST | `/v1/documents` | Yes | Upload document (multipart) |
| GET | `/v1/documents/:id` | Yes | Get document details |
| DELETE | `/v1/documents/:id` | Yes | Delete document |
| GET | `/v1/documents/:id/status` | Yes | Get processing status |
| POST | `/v1/documents/:id/chat` | Yes | Send query |
| GET | `/v1/documents/:id/chat/history` | Yes | Get chat history |
| DELETE | `/v1/documents/:id/chat` | Yes | Clear chat history |

### Environment Variables Required

```bash
# Backend API (.env)
NODE_ENV=production
PORT=3000

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Pinecone
PINECONE_API_KEY=your-pinecone-api-key
PINECONE_INDEX_NAME=brainvault-index

# Gemini
GEMINI_API_KEY=your-gemini-api-key

# Optional
LLM_PROVIDER=gemini
RATE_LIMIT_MAX=100
```

### Key File Locations

| Purpose | Mobile | API |
| --------- | -------- | ----- |
| Entry point | `lib/main.dart` | `src/index.ts` |
| Routing | `lib/app/router.dart` | `src/routes/index.ts` |
| Auth logic | `lib/features/auth/` | `src/middleware/auth.ts` |
| Document handling | `lib/features/documents/` | `src/routes/documents.routes.ts` |
| Chat/RAG | `lib/features/chat/` | `src/services/rag.service.ts` |
| API client | `lib/services/api_service.dart` | N/A |
| Theme | `lib/core/theme/` | N/A |
| Errors | `lib/core/utils/extensions.dart` | `src/errors/app-error.ts` |

---

### Document Complete

*This Architecture Decision Document is ready to guide consistent implementation of BrainVault across all development work.*
