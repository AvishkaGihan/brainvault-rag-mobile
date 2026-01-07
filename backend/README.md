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

Edit `.env` and add your configuration:

```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Firebase (from Firebase Console)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account-email

# Pinecone (from Pinecone Console)
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
