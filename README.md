# BrainVault 🧠

> **Chat with your documents.** Upload PDFs and ask natural language questions. Get accurate, cited answers powered by AI-driven Retrieval-Augmented Generation (RAG).

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-20%20LTS-green?logo=node.js)
![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue?logo=typescript)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Product Vision

BrainVault transforms how professionals, students, and researchers interact with documents — **from passive storage to active knowledge retrieval**.

### The Problem

- Reading 50-page contracts takes hours
- Finding one clause in a 200-page textbook feels impossible
- Cross-referencing research papers manually is exhausting
- Generic AI chatbots hallucinate; they don't know your documents

### The Solution

BrainVault uses **Retrieval-Augmented Generation (RAG)** to answer questions _exclusively from your uploaded content_. Every answer includes source citations, so you can verify and trust the AI.

**Key Differentiators:**
✅ **Grounded Responses** — No hallucinations, only answers from your documents
✅ **Source Citations** — Every answer includes document + page reference
✅ **Natural Conversation** — Ask follow-up questions, maintain context
✅ **Portfolio-Ready** — Full-stack architecture showcasing modern tech stack

---

## 🎯 Core Features

### MVP (Minimum Viable Product)

| Feature                    | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| **Authentication**         | Email/password + guest login via Firebase                    |
| **PDF Upload**             | Single or batch PDF uploads (max 5MB each)                   |
| **Document Processing**    | Automatic text extraction, chunking, and embedding           |
| **Natural Language Query** | Ask questions about your documents in plain English          |
| **RAG-Powered Responses**  | AI retrieves relevant context and generates grounded answers |
| **Source Citations**       | Every answer shows document name + page number               |
| **Chat History**           | Persistent conversation per document                         |
| **Document Management**    | View, organize, and delete uploaded documents                |

### Growth Features (Post-MVP)

- Text notes and web link ingestion
- Multi-document queries
- Folder organization
- PDF viewer with source highlighting
- Export chat as markdown
- Team workspaces

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App (iOS/Android)            │
│                    Material Design 3 UI Layer                   │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                    ┌─────────────┴──────────────┐
                    │ REST API (HTTPS)           │
                    │ /documents, /chat, /auth   │
                    └─────────────┬──────────────┘
                                  │
┌─────────────────────────────────┴───────────────────────────────┐
│              Node.js + Express Backend (TypeScript)             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ LangChain.js RAG Pipeline                                │  │
│  │ • PDF Loading & Text Extraction                          │  │
│  │ • Recursive Chunking (500 tokens, 50 overlap)            │  │
│  │ • Embedding Generation (Google Gemini)                   │  │
│  │ • Vector Storage (Pinecone)                              │  │
│  │ • Semantic Retrieval (Top-3 chunks)                      │  │
│  │ • LLM Response Generation (Gemini 1.5 Flash)             │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────┬──────────────────┬──────────────────────┬─────────────────┘
       │                  │                      │
       │                  │                      │
┌──────▼──────┐  ┌────────▼────────┐  ┌─────────▼──────────┐
│  Firebase   │  │    Pinecone     │  │  Google Gemini     │
│  • Auth     │  │                 │  │  LLM API           │
│  • Firestore│  │  Vector Index   │  │                    │
│  • Storage  │  │  (768 dims)     │  │  (Free Tier)       │
└─────────────┘  └─────────────────┘  └────────────────────┘
```

**Technology Stack:**

| Layer                | Technology               | Purpose                    |
| -------------------- | ------------------------ | -------------------------- |
| **Frontend**         | Flutter 3.x + Dart       | Cross-platform mobile UI   |
| **State Management** | Riverpod                 | Reactive state management  |
| **Backend**          | Node.js 20 LTS + Express | REST API server            |
| **Language**         | TypeScript               | Type-safe backend code     |
| **AI Orchestration** | LangChain.js             | RAG pipeline framework     |
| **Authentication**   | Firebase Auth            | User management            |
| **Databases**        | Firestore + Pinecone     | App data + embeddings      |
| **Storage**          | Firebase Storage         | PDF file hosting           |
| **LLM**              | Google Gemini 1.5 Flash  | Language model (swappable) |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter:** 3.x or higher ([install](https://flutter.dev/docs/get-started/install))
- **Node.js:** 20 LTS or higher ([install](https://nodejs.org))
- **Dart:** Included with Flutter
- **Git:** For version control
- **Firebase Project:** Free tier ([create](https://console.firebase.google.com))
- **Pinecone Account:** Free tier ([sign up](https://www.pinecone.io))
- **Google Gemini API Key:** Free tier ([get key](https://ai.google.dev))

### Project Setup

#### 1. Clone Repository

```bash
git clone https://github.com/yourusername/brainvault.git
cd brainvault
```

#### 2. Setup Backend (Node.js + Express)

```bash
cd api/brainvault-api

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Configure .env with your keys:
# - FIREBASE_PROJECT_ID
# - FIREBASE_PRIVATE_KEY
# - FIREBASE_CLIENT_EMAIL
# - PINECONE_API_KEY
# - PINECONE_INDEX_NAME
# - GEMINI_API_KEY
# - NODE_ENV=development

# Start development server
npm run dev
# Server runs at http://localhost:3000
```

#### 3. Setup Flutter Mobile App

```bash
cd mobile/brainvault_app

# Get Flutter dependencies
flutter pub get

# Configure Firebase
# 1. Download google-services.json from Firebase Console
# 2. Place in android/app/
# 3. Configure iOS in Xcode (Runner project settings)

# Run on connected device/emulator
flutter run

# Or build for specific platform:
flutter run -d chrome           # Web (if enabled)
flutter build apk              # Android release
flutter build ios              # iOS release
```

#### 4. Verify Setup

- **Backend Health:** `curl http://localhost:3000/health`
- **Mobile App:** Should load splash screen → welcome screen

---

## 💡 User Journey Example

### Scenario: Priya Reviews a Contract

1. **Upload** → Priya taps the upload button and selects a PDF contract
2. **Processing** → Progress indicator shows "Extracting text... Creating knowledge base..."
3. **Ready** → Document appears in list as "Contract_2024.pdf (4.2 MB, 15 pages)"
4. **Ask Question** → Priya taps the document and types: _"What's the termination clause?"_
5. **Magic Moment** → Within 4 seconds, AI responds:
   > "The contract includes the following termination provisions:
   >
   > • Either party may terminate with 30 days written notice
   > • Automatic renewal every 12 months unless terminated
   > • Early termination fee: 3 months of service charges
   >
   > **Source:** Contract_2024.pdf, Pages 12-14"
6. **Verify** → Priya taps the citation chip to confirm the exact pages
7. **Context** → She asks follow-ups: _"What about breach termination?"_ and gets related answers

---

## 📋 API Documentation

### Authentication Endpoints

**POST /auth/verify**

```bash
curl -X POST http://localhost:3000/v1/auth/verify \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"
```

### Document Endpoints

**GET /documents** — List user's documents

```bash
curl -X GET http://localhost:3000/v1/documents \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"
```

**POST /documents** — Upload PDF

```bash
curl -X POST http://localhost:3000/v1/documents \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -F "file=@contract.pdf"
```

**DELETE /documents/:id** — Delete document

```bash
curl -X DELETE http://localhost:3000/v1/documents/doc123 \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"
```

### Chat Endpoints

**POST /chat/query** — Ask a question

```bash
curl -X POST http://localhost:3000/v1/chat/query \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "documentId": "doc123",
    "query": "What is the payment schedule?",
    "conversationId": "conv456"
  }'
```

Response:

```json
{
  "id": "msg789",
  "answer": "Based on the document, the payment schedule is...",
  "citations": [
    {
      "documentId": "doc123",
      "documentName": "Contract.pdf",
      "pageNumber": 8,
      "chunkText": "..."
    }
  ],
  "timestamp": "2025-12-28T10:30:00Z"
}
```

See [API Documentation](api/README.md) for complete endpoint reference.

---

## 🏭 Development Workflow

### Backend Development

```bash
cd api/brainvault-api

# Install dependencies
npm install

# Run linter
npm run lint

# Run tests
npm test

# Run in development mode (with hot reload)
npm run dev

# Build for production
npm run build

# Start production server
npm run start
```

### Mobile Development

```bash
cd mobile/brainvault_app

# Get packages
flutter pub get

# Run linter
flutter analyze

# Run unit tests
flutter test

# Run on device
flutter run

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

### Code Standards

- **Backend:** TypeScript strict mode, ESLint configured
- **Mobile:** Dart analysis enabled, 80%+ code coverage target
- **Formatting:** Prettier (backend), `dart format` (mobile)

---

## 🧪 Testing

### Backend Tests

```bash
cd api/brainvault-api
npm test                    # Run all tests
npm test -- --coverage      # With coverage report
npm run test:integration    # Integration tests only
```

### Mobile Tests

```bash
cd mobile/brainvault_app
flutter test                # Run all tests
flutter test --coverage     # With coverage report
```

### Testing Checklist

- [ ] PDF upload and text extraction
- [ ] Embedding generation and vector storage
- [ ] RAG retrieval accuracy
- [ ] Chat message persistence
- [ ] Source citation accuracy
- [ ] Error handling and graceful failures
- [ ] Offline functionality (document list, history)

---

## 📦 Deployment

### Backend Deployment (Render.com Example)

1. Push code to GitHub
2. Connect repository to Render.com
3. Set environment variables in Render dashboard
4. Deploy — automatic on push to main

**Production Server:** https://brainvault-api.onrender.com

### Mobile Deployment

**iOS App Store:**

1. Build release IPA: `flutter build ios --release`
2. Open Runner.xcworkspace in Xcode
3. Archive and submit via App Store Connect

**Google Play Store:**

1. Build release APK: `flutter build apk --release`
2. Sign APK with keystore
3. Upload to Google Play Console

---

## 🎨 UI/UX Design

- **Design System:** Material Design 3 (Material You)
- **Color Scheme:** Deep purple primary (#6750A4), dynamic theming support
- **Typography:** System fonts for reliability
- **Animation:** Smooth transitions, optimized for performance
- **Accessibility:** WCAG AA compliant, semantic labels

See [UX Design Specification](docs/ux-design-specification.md) for detailed design guidelines.

---

## 📊 Performance Targets

| Metric                  | Target             |
| ----------------------- | ------------------ |
| **Query Response Time** | < 5 seconds        |
| **PDF Upload Time**     | < 30 seconds (5MB) |
| **Text Extraction**     | < 10 seconds       |
| **App Cold Start**      | < 3 seconds        |
| **System Uptime**       | 99% availability   |
| **Upload Success Rate** | 100% (zero crash)  |
| **Answer Accuracy**     | 90%+ relevance     |

---

## 🐛 Troubleshooting

### Backend Issues

**Port 3000 already in use:**

```bash
# Kill process using port 3000
lsof -ti:3000 | xargs kill -9
# Or change port in .env
```

**Firebase authentication fails:**

- Verify `.env` has correct Firebase credentials
- Check Firebase Security Rules in Firestore console

**Pinecone vectors not indexing:**

- Confirm Pinecone API key is valid
- Check index name matches `.env` configuration

### Mobile Issues

**Flutter build fails:**

```bash
flutter clean
flutter pub get
flutter run
```

**PDF upload fails:**

- Ensure file is < 5MB
- Verify file is valid PDF format
- Check backend is running and accessible

**Chat responses are empty:**

- Verify document has processed successfully
- Check Firebase connection
- Ensure Pinecone has indexed vectors

---

## 📚 Documentation

- [Product Requirements Document](docs/prd.md) — Vision, user journeys, success criteria
- [Architecture Decision Document](docs/architecture.md) — Technical design, technology choices
- [UX Design Specification](docs/ux-design-specification.md) — UI/UX standards, screen specs
- [API Documentation](api/brainvault-api/README.md) — Endpoint reference and examples
- [Mobile App README](mobile/brainvault_app/README.md) — Flutter setup and guidelines

---

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style and patterns
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and descriptive

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**Rusit** — Product & Full-Stack Developer

---

## 🙏 Acknowledgments

- **LangChain.js** — RAG pipeline orchestration
- **Flutter** — Cross-platform mobile framework
- **Firebase** — Backend services and infrastructure
- **Pinecone** — Vector database
- **Google Gemini** — Language model

---

## 📬 Contact & Support

Have questions or feedback? Let's connect:

- **Email:** your-email@example.com
- **Portfolio:** your-portfolio.com
- **LinkedIn:** linkedin.com/in/yourprofile
- **GitHub:** github.com/yourusername

---

## 🌟 Show Your Support

If BrainVault helps you or inspires your work, please:

- ⭐ Star this repository
- 🐛 Report bugs via Issues
- 💡 Suggest features via Discussions
- 📣 Share your experience on social media

---

**Made with ❤️ for professionals, students, and researchers who deserve better tools.**
