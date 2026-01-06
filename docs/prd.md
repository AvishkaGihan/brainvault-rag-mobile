---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
inputDocuments: ['user-provided-brief']
workflowType: 'prd'
lastStep: 11
status: complete
completedAt: '2026-01-05'
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 0
  projectDocs: 0
---

# Product Requirements Document - BrainVault

**Author:** AvishkaGihan
**Date:** January 5, 2026

## Executive Summary

**BrainVault** is an AI-powered "Second Brain" mobile application that enables users to upload documents (PDFs, text notes) and engage in natural language conversations with their content using Retrieval-Augmented Generation (RAG).

### Vision

Transform how knowledge workers interact with their documents by providing instant, accurate, citation-backed answers from their personal knowledge base — eliminating the need to manually search through lengthy documents.

### Core Value Proposition

Unlike generic AI chatbots that rely on training data, BrainVault answers questions **exclusively from the user's uploaded content**, providing:
- **Accuracy**: Answers grounded in actual document content
- **Trust**: Source citations showing exactly where information came from
- **Privacy**: User data stays within their knowledge vault

### Business Value

This project serves dual purposes:
1. **Portfolio Demonstration**: Showcases the $700 Champion Package capability (Vector Search & Custom AI Agents)
2. **Reusable Asset**: Creates a production-ready RAG boilerplate to accelerate future client deliveries

### What Makes This Special

1. **RAG-Powered Precision** — Retrieves relevant context chunks before generating answers
2. **Source Attribution** — Every answer displays "Source: Page X" for verification
3. **Full-Stack Showcase** — Demonstrates Flutter + Node.js + LangChain integration
4. **Enterprise Architecture** — Swappable LLM providers via configuration
5. **Free-Tier Optimized** — Runs entirely on Pinecone, Gemini, and Firebase free tiers

## Project Classification

| Attribute | Value |
|-----------|-------|
| **Technical Type** | Mobile App (Cross-platform) |
| **Framework** | Flutter (Dart) |
| **Domain** | AI/ML - Knowledge Management |
| **Complexity** | Medium |
| **Project Context** | Greenfield - New Project |

### Classification Rationale

- **Mobile App**: Primary interface is a Flutter mobile application targeting iOS/Android
- **AI/ML Domain**: Core functionality relies on RAG pipeline, vector embeddings, and LLM orchestration
- **Medium Complexity**: While AI integration adds complexity, the use of established tools (LangChain, Pinecone) and free-tier services reduces operational overhead

## Success Criteria

### User Success

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Time to Answer** | User gets accurate answer within 5 seconds of asking | Response time monitoring |
| **Answer Accuracy** | 90%+ of answers are factually correct based on source content | User feedback / manual testing |
| **Source Trust** | Every answer displays source citation (page/section) | Automatic verification |
| **Upload Success** | 100% of valid PDFs (≤5MB) upload without errors | Error rate tracking |
| **Learning Curve** | Users complete first query within 2 minutes of onboarding | Session analytics |

**User "Aha!" Moment:**
> "I just asked about a specific clause from a 50-page contract and got the exact answer with the page number — in 3 seconds!"

### Business Success

| Metric | Target | Timeline |
|--------|--------|----------|
| **Portfolio Impact** | Project demonstrates $700 Champion Package capability | Launch |
| **Demo Quality** | 30-second demo video shows complete flow (upload → query → cited answer) | Week 1 |
| **Code Reusability** | Backend RAG pipeline reusable for 3+ future client projects | Post-launch |
| **Client Conversations** | Project generates at least 2 client inquiries about RAG capabilities | Month 1 |
| **GitHub Stars** | Repository gains 25+ stars as social proof | Month 3 |

**Business "Win" Moment:**
> "A potential client saw the BrainVault demo and immediately asked: 'Can you build this for our internal knowledge base?'"

### Technical Success

| Metric | Target | Priority |
|--------|--------|----------|
| **Response Latency** | P95 query response < 5 seconds | Critical |
| **Embedding Quality** | Top 3 retrieved chunks contain correct answer 90%+ of time | Critical |
| **Upload Reliability** | Zero crashes on valid file uploads | Critical |
| **LLM Swappability** | Switch from Gemini to OpenAI via config change only | High |
| **Free Tier Viability** | Operates within Pinecone/Gemini/Firebase free tier limits | High |
| **Hallucination Rate** | < 5% of responses contain fabricated information | High |

### Measurable Outcomes

**Launch Checklist (Definition of Done):**
- [ ] User can authenticate (Email/Password or Guest mode)
- [ ] User can upload PDF (≤5MB) and see "Processing..." state
- [ ] System chunks PDF, generates embeddings, stores in Pinecone
- [ ] User can select document and enter chat interface
- [ ] User can ask natural language question
- [ ] System retrieves top 3 context chunks
- [ ] AI responds with answer + source citation
- [ ] Chat history persists per session
- [ ] Demo video recorded showing full user flow

## Product Scope

### MVP - Minimum Viable Product

**Must Have (Launch Blockers):**

| Feature | Description | Rationale |
|---------|-------------|-----------|
| **Authentication** | Email/Password + Guest mode via Firebase Auth | Basic user management |
| **PDF Upload** | Upload PDF files up to 5MB | Primary data ingestion |
| **Text Paste** | Paste raw text directly into app | Alternative ingestion |
| **Document Processing** | Parse → Chunk → Embed → Store pipeline | Core RAG foundation |
| **Chat Interface** | Natural language Q&A per document | Primary user interaction |
| **Source Citations** | Display "Source: Page X" with answers | Trust & differentiation |
| **Chat History** | Persist conversation per session | User experience |
| **Loading States** | "Processing..." and "Thinking..." indicators | Professional UX |

### Growth Features (Post-MVP)

**Should Have (Next Iteration):**

| Feature | Description | Value |
|---------|-------------|-------|
| **Multi-Document Query** | Chat across multiple uploaded documents | Power users |
| **Web Link Ingestion** | Paste URL → scrape and ingest content | Expanded content types |
| **Highlight Sources** | Tap citation to see highlighted original text | Enhanced trust |
| **Export Conversation** | Share or save chat as PDF/text | Productivity |
| **Folder Organization** | Organize documents into collections | Scalability |
| **Query Suggestions** | AI suggests relevant follow-up questions | Engagement |

### Vision (Future)

**Could Have (Dream Features):**

| Feature | Description | Value |
|---------|-------------|-------|
| **Voice Input** | Ask questions via voice | Accessibility |
| **OCR Integration** | Process scanned PDFs / images | Expanded content |
| **Collaborative Vaults** | Share knowledge bases with team | B2B expansion |
| **Custom AI Personas** | Configure AI tone (formal, casual, technical) | Personalization |
| **Analytics Dashboard** | Usage patterns, popular queries | Insights |
| **API Access** | Developer API for third-party integrations | Platform play |

### Out of Scope (Explicit Exclusions)

| Excluded | Reason |
|----------|--------|
| Real-time collaboration | Adds complexity, not needed for portfolio demo |
| Offline mode | Requires significant architecture changes |
| Native iOS/Android builds | Flutter cross-platform sufficient for demo |
| Admin dashboard | Beyond portfolio scope |
| Multi-language support | English-only for MVP |
| Payment/subscription | Free portfolio demo |

## User Journeys

### Journey 1: Sarah Chen - The Overwhelmed Law Student

**Character Profile:**
Sarah is a second-year law student drowning in case law readings. Every week she receives 300+ pages of contracts, precedents, and legal opinions. She's bright but exhausted — spending more time searching for specific clauses than actually analyzing them. Her study group thinks she's falling behind, but really she just can't find things fast enough.

**The Story:**

Sarah discovers BrainVault at 2 AM while stress-googling "how to search inside PDFs faster." The promise of "chat with your documents" sounds too good to be true, but she's desperate.

The next morning, she uploads her Contracts textbook PDF (4.8MB) and watches the "Processing..." animation with skepticism. When it completes, she types her first question: *"What are the elements of a valid contract?"*

In 3 seconds, BrainVault responds: *"According to your document, a valid contract requires: (1) Offer, (2) Acceptance, (3) Consideration, (4) Legal capacity, and (5) Lawful purpose. **Source: Page 47**"*

Sarah's jaw drops. She taps "Source: Page 47" and there it is — the exact paragraph she would have spent 20 minutes hunting for. She uploads three more case documents and spends the next hour asking questions like a conversation, building understanding instead of frantically flipping pages.

**The Breakthrough:**
During her study group session, someone asks about *"promissory estoppel exceptions"* — a topic buried somewhere in 80 pages of notes. While others start flipping through binders, Sarah opens BrainVault, asks the question, and reads aloud the answer with the page citation. Her study group stares in silence. By the end of the week, all four of them have BrainVault on their phones.

**Resolution:**
Sarah finishes her semester with the highest grade in Contracts. She tells her professor: *"I stopped reading documents. I started having conversations with them."*

---

### Journey 2: David Park - The Skeptical Technical Evaluator

**Character Profile:**
David is a senior developer at a mid-size insurance company. His boss just asked him to find a "ChatGPT-like thing for our policy documents." He's evaluated three solutions this week — all overpriced enterprise software with sales calls and NDAs. He finds the BrainVault GitHub repo while searching for "RAG mobile app open source."

**The Story:**

David clones the repo and starts reading the README. He's seen plenty of "AI demos" that fall apart under scrutiny. He opens the architecture diagram: *PDF → Node.js → Pinecone → LLM → Answer*. Clean. He notices the tech stack — Flutter, Express, LangChain, Gemini, Pinecone — all technologies he knows and trusts.

He spins up the backend locally, uploads a 50-page internal policy PDF, and asks: *"What's the termination clause for contractors?"*

The response: *"Contractors may be terminated with 30 days written notice or immediately for cause as defined in Section 4.2. **Source: Page 12**"*

David manually checks Page 12. It's accurate. He tries to trick it: *"What's the company's stance on aliens?"* BrainVault responds: *"I don't have information about that topic in your uploaded document."*

**The Breakthrough:**
David shows his boss the demo video and the GitHub architecture. His boss asks: "Can we hire whoever built this to customize it for us?" David finds AvishkaGihan's contact information in the repo.

**Resolution:**
Two weeks later, David's company signs a $2,500 contract for a customized BrainVault implementation for their HR policy documents. David leads the internal integration.

---

### Journey 3: Marcus Johnson - The First-Time Guest User

**Character Profile:**
Marcus is a real estate agent who received a 40-page property inspection report. His client is asking specific questions about the HVAC system, and Marcus doesn't have time to read the whole thing before their 3 PM call. He sees a LinkedIn post about BrainVault.

**The Story:**

Marcus opens BrainVault and sees the option: *"Continue as Guest"*. Perfect — he doesn't want to create another account for something he might use once. He taps it and lands on a clean home screen with a big "+" button.

He uploads the inspection report PDF and nervously watches "Processing..." — his call is in 45 minutes. The processing completes in 20 seconds. He types: *"Is there anything wrong with the HVAC system?"*

BrainVault responds: *"The inspection report identifies two HVAC concerns: (1) The condenser unit is 12 years old and showing signs of refrigerant leakage, and (2) The ductwork in the attic has disconnected sections causing efficiency loss. Estimated repair cost mentioned is $2,400-$3,800. **Source: Pages 18-19**"*

Marcus is stunned. He asks two more questions about the roof and foundation, getting instant answers with page numbers.

**The Breakthrough:**
On the call, his client asks: "What did the inspection say about the HVAC?" Marcus responds confidently, citing specific pages. His client says: "Wow, you really studied this report." Marcus smiles.

**Resolution:**
After the call, Marcus creates an account. He realizes he could upload every inspection report, every contract, every disclosure document. He'll never scramble before a client call again.

---

### Journey 4: Priya Sharma - The Knowledge Curator (Power User)

**Character Profile:**
Priya is a research consultant who works with multiple clients simultaneously. She has hundreds of PDFs: academic papers, industry reports, client briefs. She's been using BrainVault for a month and has uploaded 30+ documents. Now she needs to work smarter.

**The Story:**

Priya opens BrainVault and sees her document list growing unwieldy. She wishes she could organize them somehow. For now, she renames documents carefully: "ClientA_MarketAnalysis_2026" and "AcademicPaper_AIHealthcare_Zhang."

She's working on a healthcare AI report and needs to cross-reference three documents. Currently, she has to open each document's chat separately and manually synthesize. She makes a note to request a "multi-document query" feature.

**The Edge Case:**
Priya accidentally uploads a corrupt PDF — the file had been damaged when her laptop crashed. BrainVault shows an error: *"Unable to process this file. The PDF appears to be corrupted."* No crash, no confusion — just a clear message. She re-downloads the original from her email and uploads successfully.

**The Workaround:**
For her cross-reference needs, Priya creates a "mega-document" — she copies key excerpts from three papers into one text document and pastes it directly into BrainVault. It works! She queries across the combined content.

**Resolution:**
Priya writes a testimonial for BrainVault's GitHub: *"This app has saved me 10+ hours per week. I can finally have conversations with my research instead of drowning in tabs. Feature request: multi-document queries would make this perfect."*

---

### Journey Requirements Summary

| Journey | User Type | Key Requirements Revealed |
|---------|-----------|---------------------------|
| **Sarah (Student)** | Primary - Student | Fast processing, accurate citations, mobile-first UX |
| **David (Evaluator)** | Technical Evaluator | Clean architecture, no hallucinations, open codebase |
| **Marcus (Guest)** | Guest User | Zero-friction onboarding, guest mode, fast value |
| **Priya (Power User)** | Heavy User | Document management, error handling, text paste |

### Capabilities Needed (From Journeys)

**Authentication & Onboarding:**
- Email/Password registration
- Guest mode (no signup required)
- Quick time-to-value (under 2 minutes)

**Document Ingestion:**
- PDF upload (up to 5MB)
- Text paste option
- Clear processing status indicators
- Graceful error handling for corrupt files

**Chat & Retrieval:**
- Natural language questions
- Sub-5-second response time
- Source citations with page numbers
- Hallucination prevention ("I don't know")

**Document Management:**
- Document list view
- Document renaming
- Per-document chat history

**Portfolio & Business:**
- Clean GitHub README with architecture diagram
- Demo video showing full flow
- Contact information for inquiries

## Domain-Specific Requirements

### AI/ML Domain - RAG System Best Practices

Since BrainVault is an AI-powered RAG (Retrieval-Augmented Generation) system, the following domain-specific requirements apply:

### Key AI/ML Concerns

| Concern | Requirement | Implementation |
|---------|-------------|----------------|
| **Answer Accuracy** | Responses must be grounded in source documents | Strict system prompt: "Answer ONLY from provided context" |
| **Hallucination Prevention** | System must not fabricate information | Return "I don't know" when context is insufficient |
| **Source Attribution** | Every answer must cite its source | Include page/section metadata with each response |
| **Retrieval Quality** | Top-K chunks must contain relevant context | Tune chunk size and overlap parameters |
| **Embedding Quality** | Semantic similarity must capture intent | Use high-quality embedding model (text-embedding-004) |

### RAG Pipeline Best Practices

**Document Processing:**
- Chunk size: 500-1000 tokens (optimal for Q&A retrieval)
- Chunk overlap: 10-20% (maintains context continuity)
- Metadata preservation: Page numbers, section headers, document ID

**Retrieval Configuration:**
- Top-K: 3-5 chunks (balance between context and noise)
- Similarity threshold: 0.7+ (filter irrelevant matches)
- Reranking: Optional - improves precision for complex queries

**Prompt Engineering:**
```
System Prompt:
"You are a helpful assistant that answers questions based ONLY on the provided context.
If the answer is not in the context, respond: 'I don't have information about that in your document.'
Always cite your source with the page number when available."
```

### Validation Methodology

| Validation Type | Method | Success Criteria |
|-----------------|--------|------------------|
| **Retrieval Accuracy** | Manual testing with known answers | 90%+ correct chunk retrieval |
| **Answer Accuracy** | Human evaluation of 50+ queries | 90%+ factually correct |
| **Hallucination Check** | Out-of-scope query testing | 100% "I don't know" responses |
| **Latency Testing** | Load testing under realistic conditions | P95 < 5 seconds |

### AI Safety Considerations

- **No PII in prompts**: User queries may contain sensitive information; ensure logs don't expose PII
- **Rate limiting**: Prevent abuse of AI inference endpoints
- **Context isolation**: Ensure user A cannot access user B's document context
- **Model transparency**: Document which LLM version is used for reproducibility

## Innovation & Differentiation

### Innovation Assessment

BrainVault is **execution-focused** rather than technology-focused. It does not introduce breakthrough innovations but instead demonstrates **production-quality implementation** of established AI/ML patterns.

### Value Differentiation (What Sets It Apart)

| Aspect | Common Approach | BrainVault Approach | Advantage |
|--------|-----------------|---------------------|-----------|
| **RAG Demo** | Web-only, desktop-first | Mobile-first Flutter app | Cross-platform portfolio appeal |
| **Source Citations** | Often missing or vague | Page-level attribution | Trust & verification |
| **LLM Provider** | Hardcoded to one provider | Config-swappable architecture | Enterprise flexibility |
| **Free Tier Focus** | Expensive services | Pinecone/Gemini/Firebase free | Cost-conscious clients |
| **Hallucination Handling** | Hope for the best | Strict "I don't know" prompt | Production reliability |

### Why This Matters for Portfolio

**For Potential Clients:**
- Proves you can deliver working AI products (not just prototypes)
- Shows cost-conscious architecture decisions
- Demonstrates mobile + backend + AI integration

**For Technical Evaluators:**
- Clean architecture diagram shows mature thinking
- Swappable LLM shows foresight
- Free-tier focus shows practical engineering

### Competitive Landscape

| Competitor Type | Example | BrainVault Advantage |
|-----------------|---------|---------------------|
| Generic ChatGPT wrappers | ChatPDF, Humata | User-owned data, source citations |
| Enterprise RAG | Glean, Guru | Open-source, customizable, no vendor lock-in |
| Document search | Notion AI, Coda | Mobile-first, dedicated Q&A interface |

### Validation Approach

Since BrainVault is execution-focused, validation is straightforward:

1. **Technical Validation:** Does the RAG pipeline return correct chunks?
2. **User Validation:** Do users trust the citations?
3. **Portfolio Validation:** Does it generate client inquiries?

## Mobile App Specific Requirements

### Project-Type Overview

BrainVault is a **cross-platform mobile application** built with Flutter targeting both iOS and Android. The app prioritizes **simplicity and fast time-to-value** over native feature complexity.

### Platform Requirements

| Platform | Target | Build Output | Notes |
|----------|--------|--------------|-------|
| **Android** | API 21+ (Android 5.0+) | APK / AAB | Primary demo platform |
| **iOS** | iOS 12+ | Simulator screenshots | Secondary, for portfolio screenshots |
| **Web** | Not targeted | — | Flutter web possible but not prioritized |

**Cross-Platform Strategy:**
- Single Flutter codebase
- Material Design 3 for consistent UI across platforms
- Platform-agnostic file picker for document selection
- No platform-specific native code required for MVP

### Device Permissions

| Permission | Android | iOS | Purpose | Required |
|------------|---------|-----|---------|----------|
| **Internet** | `INTERNET` | Default | API calls to backend | ✅ Yes |
| **Read Storage** | `READ_EXTERNAL_STORAGE` | Photo Library | PDF file selection | ✅ Yes |
| **Camera** | `CAMERA` | Camera | Document scanning (future) | ❌ No (MVP) |
| **Notifications** | `POST_NOTIFICATIONS` | Push Notifications | — | ❌ No (MVP) |

**Permission Request Flow:**
1. On first "Upload PDF" action, request storage permission
2. Show rationale: "BrainVault needs access to select PDF files"
3. Handle denial gracefully with text paste fallback

### Offline Mode Consideration

| Feature | Online Required | Offline Capable |
|---------|-----------------|-----------------|
| **Document Upload** | ✅ Yes | ❌ No |
| **Chat Query** | ✅ Yes (RAG needs backend) | ❌ No |
| **View Chat History** | ❌ No (cached locally) | ✅ Yes |
| **View Document List** | ❌ No (cached locally) | ✅ Yes |

**Decision:** Full offline mode is **out of scope** for MVP. The core RAG functionality requires backend connectivity. Local caching of document list and chat history provides acceptable UX during brief disconnections.

### Push Notification Strategy

**MVP Decision:** No push notifications required.

**Rationale:**
- Document processing is near-instant (< 30 seconds)
- Users wait for "Processing..." to complete
- No background processing that needs notification

**Future Consideration:**
- Notify when long document processing completes
- Daily digest: "You haven't queried your documents in 3 days"

### App Store Compliance

**Google Play Store:**

| Requirement | Status | Notes |
|-------------|--------|-------|
| **Target API Level** | API 34 (Android 14) | Required for new submissions |
| **64-bit Support** | ✅ Flutter default | ARM64 + x86_64 |
| **Privacy Policy** | ⚠️ Required | Must create before submission |
| **Data Safety Form** | ⚠️ Required | Document: email, documents stored |
| **Content Rating** | Everyone | No mature content |

**Apple App Store:**

| Requirement | Status | Notes |
|-------------|--------|-------|
| **iOS Deployment Target** | iOS 12+ | Covers 99%+ of devices |
| **Privacy Nutrition Labels** | ⚠️ Required | Document data collection |
| **App Review Guidelines** | 4.2 (Minimum Functionality) | Must demonstrate value |

**Privacy Policy Requirements:**
- What data is collected (email, uploaded documents)
- How data is stored (Firebase, Pinecone)
- User rights (delete account, delete documents)
- Third-party services (Gemini API)

### Technical Architecture Considerations

**Flutter Architecture:**

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp configuration
│   └── routes.dart              # Navigation routes
├── features/
│   ├── auth/                    # Authentication feature
│   │   ├── data/                # Repositories, data sources
│   │   ├── domain/              # Entities, use cases
│   │   └── presentation/        # Screens, widgets, providers
│   ├── documents/               # Document management feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── chat/                    # Chat/Q&A feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── core/
│   ├── network/                 # Dio configuration
│   ├── theme/                   # Material Design 3 theme
│   └── utils/                   # Shared utilities
└── shared/
    └── widgets/                 # Reusable widgets
```

**State Management:**
- Provider or Riverpod (as specified in brief)
- Recommendation: **Riverpod** for better testability and compile-time safety

**Networking:**
- Dio for HTTP requests
- Multipart form data for PDF uploads
- Interceptors for auth token injection

### UI/UX Specifications

**Design System:**
- Material Design 3 (Material You)
- Dynamic color theming based on device wallpaper (Android 12+)
- Light and dark mode support

**Key Screens:**

| Screen | Purpose | Key Components |
|--------|---------|----------------|
| **Splash** | App initialization | Logo, loading indicator |
| **Auth** | Login/Register/Guest | Email field, password field, guest button |
| **Home** | Document list | Document cards, FAB for upload |
| **Upload** | Add new document | File picker, text paste area, processing indicator |
| **Chat** | Q&A interface | Message list, input field, source chips |

**Loading States:**
- "Processing..." with progress indicator during document ingestion
- "Thinking..." with skeleton loader during AI inference
- Pull-to-refresh for document list

### Implementation Considerations

**Critical Path Dependencies:**
1. Firebase Auth SDK must be configured first
2. Backend API must be deployed before mobile integration testing
3. PDF file picker requires storage permissions

**Testing Strategy:**
- Unit tests: Business logic, state management
- Widget tests: UI components
- Integration tests: Auth flow, upload flow, chat flow

**Performance Targets:**
- App cold start: < 2 seconds
- Document list load: < 500ms
- Chat response display: Streaming preferred, or < 5s total

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Experience MVP
**Rationale:** Portfolio projects must demonstrate polished user experience in a 30-second demo. Technical depth matters, but user delight sells.

**Resource Requirements:**
- Team Size: 1 (Solo Developer)
- Timeline: 5 Days
- Skills Needed: Flutter, Node.js/Express, LangChain, Firebase

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
1. ✅ Sarah (Student) — Upload PDF, ask questions, get cited answers
2. ✅ Marcus (Guest) — Zero-friction demo experience
3. ⚠️ David (Evaluator) — Requires clean GitHub + README (non-app work)
4. ⚠️ Priya (Power User) — Limited; single-doc only

**Must-Have Capabilities (MVP):**

| Capability | User Value | Technical Component |
|------------|------------|---------------------|
| **Guest + Email Auth** | Zero friction entry | Firebase Auth |
| **PDF Upload (≤5MB)** | Primary data ingestion | Dio multipart + Firebase Storage |
| **Text Paste** | Fallback ingestion | Direct API call |
| **Processing Status** | User confidence | Backend status endpoint |
| **Chat Q&A** | Core product value | LangChain RAG pipeline |
| **Source Citations** | Trust & differentiation | Metadata in Pinecone |
| **Chat History** | Conversation continuity | Firestore per-document |
| **Document List** | Content management | Firestore query |
| **Loading States** | Professional UX | Flutter skeleton loaders |

**Explicitly NOT in MVP:**
- ❌ Multi-document queries
- ❌ Web link ingestion
- ❌ Folder organization
- ❌ Export conversation
- ❌ Voice input
- ❌ OCR for scanned PDFs

### Post-MVP Features

**Phase 2 (Growth - Week 2-4):**

| Feature | User Value | Complexity |
|---------|------------|------------|
| **Multi-Document Query** | Cross-reference research | Medium |
| **Web Link Ingestion** | URL → knowledge | Medium |
| **Highlight Sources** | Tap citation → see original | Medium |
| **Document Renaming** | Better organization | Low |
| **Query Suggestions** | Guided discovery | Low |

**Phase 3 (Expansion - Month 2+):**

| Feature | User Value | Complexity |
|---------|------------|------------|
| **Folder Organization** | Scalable document management | Medium |
| **Export Conversation** | Share insights | Low |
| **Voice Input** | Hands-free queries | Medium |
| **OCR Integration** | Scanned document support | High |
| **Collaborative Vaults** | Team knowledge sharing | High |
| **API Access** | Developer integrations | High |

### Risk Mitigation Strategy

**Technical Risks:**

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Gemini API latency | Medium | High | Implement streaming responses; engaging loading UI |
| Pinecone free tier limits | Low | Medium | Monitor usage; chunk efficiently |
| PDF parsing failures | Medium | Medium | Graceful error handling; text paste fallback |
| LLM hallucination | Medium | High | Strict system prompt; "I don't know" default |

**Market Risks:**

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| "Just use ChatGPT" objection | High | Medium | Emphasize source citations & user-owned data |
| Portfolio doesn't generate leads | Medium | High | Strong demo video; architecture diagram; clear contact |

**Resource Risks:**

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 5-day timeline too tight | Medium | High | Cut text paste if needed; focus on PDF flow |
| Backend complexity underestimated | Low | Medium | Use LangChain abstractions; copy proven patterns |
| Firebase config issues | Low | Low | Follow official Flutter Firebase setup guides |

### Development Timeline (5-Day Sprint)

| Day | Focus | Deliverables |
|-----|-------|--------------|
| **Day 1** | Setup & Auth | Flutter project, Firebase Auth, UI skeleton |
| **Day 2** | Backend Core | Node.js/Express, Pinecone connection, PDF upload endpoint |
| **Day 3** | RAG Pipeline | LangChain integration, embedding generation, retrieval |
| **Day 4** | Chat UI | Chat interface, connect to RAG endpoint, source citations |
| **Day 5** | Polish & Demo | Error handling, loading states, demo video recording |

**Contingency:** If behind schedule on Day 3, simplify to single-query mode (no chat history).

## Functional Requirements

### User Authentication

| ID | Requirement |
|----|-------------|
| **FR1** | User can create an account using email and password |
| **FR2** | User can log in with existing email and password credentials |
| **FR3** | User can continue as a guest without creating an account |
| **FR4** | User can log out of their account |
| **FR5** | User can reset their password via email |
| **FR6** | System maintains user session across app restarts |

### Document Ingestion

| ID | Requirement |
|----|-------------|
| **FR7** | User can upload a PDF file from their device |
| **FR8** | System accepts PDF files up to 5MB in size |
| **FR9** | System rejects PDF files exceeding 5MB with clear error message |
| **FR10** | User can paste plain text directly into the app as a document |
| **FR11** | System displays processing status while document is being ingested |
| **FR12** | System notifies user when document processing is complete |
| **FR13** | System displays error message if document processing fails |
| **FR14** | User can cancel document upload before processing completes |

### Knowledge Processing (Backend)

| ID | Requirement |
|----|-------------|
| **FR15** | System extracts text content from uploaded PDF files |
| **FR16** | System splits document text into semantic chunks |
| **FR17** | System generates vector embeddings for each chunk |
| **FR18** | System stores embeddings with metadata (document ID, page number) |
| **FR19** | System preserves page number information for source attribution |
| **FR20** | System associates all document data with the uploading user |

### Chat & Retrieval

| ID | Requirement |
|----|-------------|
| **FR21** | User can enter a natural language question about a document |
| **FR22** | System retrieves the top 3 most relevant context chunks for a query |
| **FR23** | System generates an answer using retrieved context and LLM |
| **FR24** | System displays source citation (page number) with each answer |
| **FR25** | User can tap source citation to identify the referenced page |
| **FR26** | System responds with "I don't have information about that" when context is insufficient |
| **FR27** | User can view chat history for the current document session |
| **FR28** | System persists chat history per document |
| **FR29** | User can start a new conversation within the same document |
| **FR30** | System displays "Thinking..." indicator while generating response |

### Document Management

| ID | Requirement |
|----|-------------|
| **FR31** | User can view a list of all their uploaded documents |
| **FR32** | User can select a document to enter its chat interface |
| **FR33** | User can delete a document from their knowledge base |
| **FR34** | System confirms deletion before removing document |
| **FR35** | User can see document metadata (name, upload date, size) |
| **FR36** | System displays documents in reverse chronological order (newest first) |

### System Feedback & Error Handling

| ID | Requirement |
|----|-------------|
| **FR37** | System displays appropriate loading indicators during all async operations |
| **FR38** | System displays user-friendly error messages for all failure scenarios |
| **FR39** | User can retry failed operations (upload, query) |
| **FR40** | System gracefully handles network disconnection during operations |
| **FR41** | System provides clear feedback when user exceeds free tier limits |

### Requirements Traceability

| Capability Area | FR Count | Journey Coverage |
|-----------------|----------|------------------|
| **User Authentication** | 6 | Sarah, Marcus, Priya |
| **Document Ingestion** | 8 | Sarah, Marcus, Priya |
| **Knowledge Processing** | 6 | (Backend - all journeys) |
| **Chat & Retrieval** | 10 | Sarah, Marcus, David |
| **Document Management** | 6 | Priya |
| **System Feedback** | 5 | All journeys |
| **TOTAL** | **41** | — |

### Completeness Validation

✅ All MVP capabilities from scoping section covered
✅ All user journey touchpoints have corresponding FRs
✅ Domain requirements (hallucination prevention) → FR26
✅ Project-type requirements (loading states) → FR30, FR37
✅ Error handling for Priya's corrupt PDF journey → FR13, FR38

## Non-Functional Requirements

### Performance

| ID | Requirement | Target | Priority |
|----|-------------|--------|----------|
| **NFR1** | Query response time (end-to-end) | P95 < 5 seconds | Critical |
| **NFR2** | Document processing time (5MB PDF) | < 30 seconds | High |
| **NFR3** | App cold start time | < 2 seconds | High |
| **NFR4** | Document list load time | < 500ms | Medium |
| **NFR5** | Time to first meaningful paint | < 1 second | Medium |

**Performance Context:**
- Response time includes: API call → Pinecone retrieval → LLM inference → response display
- Free tier services may have cold start latency; mitigate with engaging loading UI
- Streaming responses preferred to reduce perceived latency

### Security

| ID | Requirement | Implementation | Priority |
|----|-------------|----------------|----------|
| **NFR6** | API keys never stored in mobile app code | Backend environment variables only | Critical |
| **NFR7** | User documents isolated per user account | Pinecone namespace per user | Critical |
| **NFR8** | All API communication over HTTPS | TLS 1.2+ enforced | Critical |
| **NFR9** | Firebase Auth tokens validated on every API call | Token verification middleware | Critical |
| **NFR10** | User can delete their documents and associated data | Cascade delete in Pinecone + Firestore | High |
| **NFR11** | No PII logged in application logs | Sanitize logs before persistence | High |

**Security Context:**
- User documents may contain contracts, financial info, or personal notes
- Guest mode users should have temporary, isolated data
- GEMINI_API_KEY exposure would cause billing issues

### Reliability

| ID | Requirement | Target | Priority |
|----|-------------|--------|----------|
| **NFR12** | Document upload success rate | 99% for valid PDFs (≤5MB) | Critical |
| **NFR13** | Chat query availability | 99% uptime during demo hours | High |
| **NFR14** | Graceful degradation on service failure | User-friendly error messages | High |
| **NFR15** | Data persistence | No data loss after successful upload | Critical |

**Reliability Context:**
- Portfolio demos must work flawlessly — a crash during demo loses the client
- External dependencies (Gemini, Pinecone) may have outages; handle gracefully

### Usability

| ID | Requirement | Target | Priority |
|----|-------------|--------|----------|
| **NFR16** | Time to first successful query | < 3 minutes from app open | High |
| **NFR17** | Guest mode zero-friction | No signup required to try | Critical |
| **NFR18** | Loading states for all async operations | 100% coverage | High |
| **NFR19** | Error messages actionable | User knows what to do next | High |
| **NFR20** | Mobile-first responsive design | Works on phones 5"+ | High |

**Usability Context:**
- First impression matters for portfolio — users should feel success quickly
- Technical evaluators will try to break it; handle edge cases gracefully

### Scalability (Limited Scope)

| ID | Requirement | Target | Priority |
|----|-------------|--------|----------|
| **NFR21** | Support concurrent users | 10 simultaneous users | Low |
| **NFR22** | Documents per user | Up to 20 documents | Low |
| **NFR23** | Pinecone free tier limits | 100,000 vectors total | Informational |

**Scalability Context:**
- Portfolio project — not expecting viral growth
- Free tier limits documented to manage expectations
- Architecture supports scaling if needed (swap to paid tiers)

### Maintainability

| ID | Requirement | Implementation | Priority |
|----|-------------|----------------|----------|
| **NFR24** | LLM provider swappable | Config-based provider selection | High |
| **NFR25** | Clean code architecture | Feature-based folder structure | Medium |
| **NFR26** | Environment-based configuration | .env files for all environments | High |
| **NFR27** | Code documentation | README with setup instructions | Critical |

**Maintainability Context:**
- Codebase should serve as boilerplate for future client projects
- Technical evaluators will read the code; quality matters

### Accessibility (Basic)

| ID | Requirement | Target | Priority |
|----|-------------|--------|----------|
| **NFR28** | Minimum touch target size | 48x48 dp | Medium |
| **NFR29** | Color contrast ratio | 4.5:1 minimum | Medium |
| **NFR30** | Screen reader compatibility | Core flows accessible | Low |

**Accessibility Context:**
- Basic accessibility is good practice and demonstrates professionalism
- Not primary focus for portfolio demo

### NFR Summary

| Category | Count | Priority Mix |
|----------|-------|--------------|
| **Performance** | 5 | 1 Critical, 2 High, 2 Medium |
| **Security** | 6 | 4 Critical, 2 High |
| **Reliability** | 4 | 2 Critical, 2 High |
| **Usability** | 5 | 1 Critical, 4 High |
| **Scalability** | 3 | 2 Low, 1 Informational |
| **Maintainability** | 4 | 1 Critical, 1 High, 2 Medium |
| **Accessibility** | 3 | 2 Medium, 1 Low |
| **TOTAL** | **30** | — |

