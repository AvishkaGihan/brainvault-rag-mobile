# BrainVault RAG API

Node.js/Express backend API for BrainVault, powered by LangChain and Pinecone for RAG (Retrieval-Augmented Generation) capabilities.

## 📋 Prerequisites

- **Node.js** v18+ ([Download](https://nodejs.org/))
- **npm** v9+ (comes with Node.js)
- **Git** for version control

Verify installation:

```bash
node --version  # Should be v18+
npm --version   # Should be v9+
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

This installs all dependencies including:

- Express.js (web framework)
- TypeScript (type safety)
- ts-node & nodemon (development hot-reload)
- LangChain (RAG framework)
- Pinecone (@pinecone-database/pinecone)
- Firebase Admin SDK
- PDF parsing and utilities

### 2. Configure Environment Variables

Create a `.env` file in the project root (copy from `.env.example`):

```bash
cp .env.example .env
```

#### Firebase Setup (Story 1.3)

You need Firebase credentials to run the backend. Here's how to set them up:

**Step 1: Get Firebase Service Account Credentials**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **brainvault** (Project ID: your-project-id)
3. Click ⚙️ **Project Settings** (top right)
4. Go to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the JSON file securely

**Step 2: Add Credentials to .env**

Edit `.env` and add your configuration. You have two options:

**Option A: Complete JSON Credentials (Recommended)**

```env
FIREBASE_CREDENTIALS='{"type":"service_account","project_id":"your-project-id","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"..."}'
```

**Option B: Individual Fields**

```env
FIREBASE_PROJECT_ID=brainvault-46438
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@brainvault-46438.iam.gserviceaccount.com
```

#### Pinecone Setup (Story 1.4)

Pinecone is the vector database for storing and querying document embeddings. Set up a free-tier account:

**Step 1: Create Pinecone Account & Project**

1. Go to [Pinecone Console](https://app.pinecone.io)
2. Sign up or log in (create free account if needed)
3. Create a new project (or select existing one)

**Step 2: Create Index**

1. Click **+ Create Index**
2. Configure with these settings:
   - **Name:** `brainvault-index`
   - **Dimension:** `768` (matches text-embedding-004 model)
   - **Metric:** `Cosine` (optimal for semantic search)
   - **Cloud:** `AWS`
   - **Region:** `us-east-1` (free tier)
   - **Pod type:** `Starter` (free tier)
3. Click **Create Index**
4. Wait for index to reach "Ready" status (usually 1-2 minutes)

**Step 3: Get API Key**

1. Go to **API Keys** (sidebar)
2. Copy your API Key (keep it secure, don't commit to git)

**Step 4: Add to .env**

```env
PINECONE_API_KEY=your-copied-api-key
PINECONE_INDEX=brainvault-index
```

**Verify Configuration:**

Run the test suite to verify Pinecone is configured correctly:

```bash
npm test -- tests/unit/pinecone.test.ts
```

Expected output:

```
PASS  tests/unit/pinecone.test.ts
  Pinecone Client Configuration
    ✓ should initialize Pinecone client with valid API key
    ✓ should connect to brainvault-index
  Vector Metadata Schema
    ✓ should have correct metadata schema with all required fields
    ✓ should enforce correct field types and constraints
  ...
  Tests: 17 passed, 17 total
```

**Troubleshooting Pinecone:**

| Issue                      | Solution                                                         |
| -------------------------- | ---------------------------------------------------------------- |
| "Connection Failed"        | Verify API key is correct (no extra spaces)                      |
| "Invalid Vector Dimension" | Ensure using 768-dim embeddings (text-embedding-004)             |
| "Rate Limit (429)"         | Free tier: max 3 requests/sec. Add exponential backoff           |
| "Index Not Found"          | Verify index name is exactly `brainvault-index` (case-sensitive) |

**Free Tier Limits:**

- Max vectors: 100,000 (easily handles 20 docs × 100 chunks each)
- Max requests/sec: 3 (adequate for development)
- Max metadata size: ~40KB per vector
- Metadata fields: Max 10 (using 5: userId, documentId, pageNumber, chunkIndex, textPreview)

**Metadata Schema:**

Vectors stored in Pinecone include metadata for user isolation and source tracking:

- `userId` - User ID (primary isolation mechanism)
- `documentId` - Document ID (links to source)
- `pageNumber` - Page number (source attribution)
- `chunkIndex` - Chunk order (sequence tracking)
- `textPreview` - First 200 chars (UI preview)

Edit `.env` and add your complete configuration:

```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Firebase (from Firebase Console - Story 1.3)
FIREBASE_CREDENTIALS='{"type":"service_account","project_id":"your-project-id",...}'
# OR use individual fields if FIREBASE_CREDENTIALS not set

# Pinecone (from Pinecone Console - Story 1.4)
PINECONE_API_KEY=your-api-key
PINECONE_INDEX=brainvault-index

# LLM Configuration
LLM_PROVIDER=gemini
GOOGLE_API_KEY=your-google-api-key

# Optional: Other LLM Providers (if using)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
```

> ⚠️ **Security Note:** Never commit `.env` to version control. It's already in `.gitignore`.

### 3. Start Development Server

```bash
npm run dev
```

Server will start with hot-reload enabled. Any changes to `src/**` files will automatically restart the server.

Expected output:

```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║           🧠 BrainVault RAG API Started               ║
║                                                        ║
║  Server:     http://localhost:3000                    ║
║  Environment: development                             ║
║  Status:     ✓ Ready to accept requests              ║
║                                                        ║
║  Health Check: GET /api/health                        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

### 4. Test Health Endpoint

```bash
curl http://localhost:3000/api/health
```

Expected response:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "uptime": 42,
    "timestamp": "2026-01-07T10:30:00Z"
  },
  "meta": {
    "timestamp": "2026-01-07T10:30:00Z"
  }
}
```

## 📂 Project Structure

```
backend/
├── src/
│   ├── index.ts                    # Express app entry point
│   ├── config/
│   │   ├── index.ts                # Configuration exports
│   │   ├── env.ts                  # Environment variable loader
│   │   ├── firebase.ts             # Firebase Admin SDK
│   │   ├── pinecone.ts             # Pinecone client
│   │   └── llm.ts                  # LLM provider factory
│   ├── routes/
│   │   ├── index.ts                # Route aggregator
│   │   └── health.routes.ts        # Health check endpoint
│   ├── controllers/
│   │   └── health.controller.ts    # Health check handler
│   ├── services/
│   │   └── (business logic)
│   ├── middleware/
│   │   └── error.middleware.ts     # Error handling
│   ├── types/
│   │   ├── index.ts                # Type exports
│   │   └── api.types.ts            # API response types
│   └── utils/
│       └── (utility functions)
├── tests/
│   ├── unit/                       # Unit tests
│   ├── integration/                # Integration tests
│   └── fixtures/                   # Test fixtures
├── package.json
├── tsconfig.json
├── nodemon.json
├── .env.example
├── .gitignore
├── README.md
└── dist/                           # Compiled JavaScript (generated)
```

## 🛠️ Available Scripts

### Development

```bash
# Start development server with hot-reload
npm run dev
```

### Building

```bash
# Compile TypeScript to JavaScript
npm run build

# Output directory: ./dist
```

### Production

```bash
# Start compiled server (requires npm run build first)
npm start
```

### Testing

```bash
# Run test suite (placeholder - implement with Jest)
npm test
```

## 📡 API Endpoints

### Health Check

```
GET /api/health
```

Returns server health status and uptime.

**Response:**

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "uptime": 120,
    "timestamp": "2026-01-07T10:30:00Z"
  },
  "meta": {
    "timestamp": "2026-01-07T10:30:00Z"
  }
}
```

More endpoints will be added in subsequent stories.

## 🏗️ Architecture

### Service-Oriented Architecture

- **Controllers** - Handle HTTP requests
- **Services** - Contain business logic
- **Routes** - Define API endpoints
- **Middleware** - Handle cross-cutting concerns (auth, errors, logging)
- **Config** - Manage dependencies and external services
- **Types** - Centralized TypeScript interfaces

### Standard API Response Format

All endpoints return a standard structure:

```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: { code: string; message: string; details?: Record<string, unknown> };
  meta: { timestamp: string; count?: number };
}
```

### Error Handling

- Global error middleware catches all exceptions
- Errors formatted consistently
- Proper HTTP status codes (400, 401, 404, 500, etc.)
- Detailed logging with timestamps

## 🔧 Development Workflow

### Hot-Reload with Nodemon

Nodemon automatically restarts the server when you modify files in `src/`:

```bash
npm run dev  # Watches src/** for changes
```

### TypeScript Compilation

The project uses TypeScript strict mode for type safety:

```bash
npm run build  # Compile src/ to dist/
```

Check `tsconfig.json` for compilation settings.

### Code Style

**File Naming:**

- Files: kebab-case (e.g., `auth.service.ts`)
- Directories: kebab-case (e.g., `src/services/`)

**Code Style:**

- Classes: PascalCase (e.g., `HealthController`)
- Functions/methods: camelCase (e.g., `getHealth()`)
- Constants: SCREAMING_SNAKE_CASE (e.g., `MAX_FILE_SIZE`)

## 📦 Key Dependencies

### Core Framework

- **express** - Web framework
- **typescript** - Type safety
- **cors** - Cross-origin requests
- **dotenv** - Environment variables

### RAG & AI

- **langchain** - RAG framework for orchestrating LLM chains
- **@langchain/google-genai** - Google Gemini provider
- **@pinecone-database/pinecone** - Vector database client
- **firebase-admin** - Authentication and database

### Utilities

- **multer** - File upload handling
- **pdf-parse** - PDF text extraction
- **express-rate-limit** - Rate limiting middleware

### Development

- **ts-node** - Execute TypeScript directly
- **nodemon** - Auto-reload on file changes
- **@types/** - TypeScript definitions

## 🐛 Troubleshooting

### Firebase Connection Issues

**Error: `Missing required environment variable: FIREBASE_CREDENTIALS`**

- Ensure `.env` file exists in the project root
- Add either `FIREBASE_CREDENTIALS` (JSON) or individual Firebase variables
- Verify credentials JSON is valid (no extra quotes or escape issues)

**Error: `Failed to initialize Firebase Admin SDK`**

- Check that Firebase project ID matches your project ID
- Verify service account credentials were downloaded from correct project
- Ensure private key includes `-----BEGIN PRIVATE KEY-----` markers

**Firebase credentials in different formats:**

If you exported the key from Firebase Console, it may need formatting:

```bash
# If FIREBASE_PRIVATE_KEY shows literal \n instead of newlines:
# Replace them with actual newlines in your .env file

# Incorrect:
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEv..."

# Correct: Use actual newlines in multi-line format
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIIEv...
-----END PRIVATE KEY-----"
```

### Port Already in Use

If you get `EADDRINUSE: address already in use`:

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
PORT=3001 npm run dev
```

### TypeScript Errors

Ensure TypeScript strict mode passes:

```bash
npx tsc --noEmit  # Check without compiling
```

### Missing Dependencies

Reinstall node_modules:

```bash
rm -rf node_modules package-lock.json
npm install
```

### Environment Variable Issues

Check that `.env` file exists and contains required variables:

```bash
cat .env
```

Compare with `.env.example` if missing fields.

## 📚 References

- [Express Documentation](https://expressjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [LangChain Documentation](https://langchain.com/docs/)
- [Pinecone Documentation](https://docs.pinecone.io/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## 📝 License

MIT - See LICENSE file for details

## 👤 Author

**AvishkaGihan** - BrainVault Project Lead

---

**Last Updated:** January 7, 2026
**Status:** ✓ Initialized and Ready for Development
