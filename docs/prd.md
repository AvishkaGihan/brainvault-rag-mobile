---
stepsCompleted: [1, 2, 3, 4, 7, 8, 9, 10, 11]
inputDocuments:
  - "User-provided PRD Brief (BrainVault AI Knowledge Assistant)"
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 0
  projectDocs: 0
workflowType: 'prd'
lastStep: 11
status: 'complete'
completedDate: '2025-12-21'
project_name: 'brainvault-rag-mobile'
user_name: 'Rusit'
date: '2025-12-21'
---

# Product Requirements Document - brainvault-rag-mobile

**Author:** Rusit  
**Date:** 2025-12-21

---

## Executive Summary

**BrainVault** is a "Second Brain" mobile application that enables users to capture knowledge (text notes, PDF documents, or web links) and interact with their data through AI-powered natural language conversations. Unlike generic chatbots that generate responses from their training data, BrainVault uses **Retrieval-Augmented Generation (RAG)** to answer questions exclusively from the user's uploaded content, providing accurate, source-cited responses.

### Vision Statement

"Transform how professionals, students, and researchers interact with their documents — from passive storage to active knowledge retrieval."

### Strategic Value

- **User Value:** Instantly retrieve specific details from lengthy documents without reading them
- **Business Value:** Demonstrates the $700 Champion Package capability (Vector Search & Custom Agents) — a reusable RAG boilerplate for accelerated client delivery
- **Portfolio Value:** Full-stack showcase — Flutter mobile + Node.js API + LangChain AI + Vector DB

### What Makes This Special

1. **RAG-Powered Precision:** Responses are grounded in user content, not hallucinated from general training data
2. **Source Citations:** Every answer includes document reference (e.g., "Source: Page 4") for verification and trust
3. **Full-Stack Architecture:** Cross-platform mobile (Flutter) + Scalable backend (Node.js/Express) + AI orchestration (LangChain.js)
4. **Provider Agnostic:** Architecture supports swapping LLM providers (Gemini ↔ Llama via Replicate) via configuration
5. **Portfolio Ready:** Designed for demo videos and README diagrams that impress B2B clients

## Project Classification

**Technical Type:** Mobile Application (Cross-platform)  
**Domain:** EdTech / Knowledge Management  
**Complexity:** Medium  
**Project Context:** Greenfield — new project from scratch

### Technical Classification Breakdown

| Aspect | Classification | Rationale |
| --- | --- | --- |
| Platform | Cross-platform Mobile (Flutter) | Single codebase for iOS/Android, portfolio flexibility |
| Backend | Node.js + Express + TypeScript | Modern stack, strong async handling for AI operations |
| AI Layer | LangChain.js + RAG Pipeline | Industry-standard orchestration, modular design |
| Data Layer | Vector DB (Pinecone) + Document DB (Firestore) | Separation of concerns: embeddings vs. metadata |
| Auth | Firebase Authentication | Rapid implementation, reliable, free tier available |

### Domain Considerations

This falls into the **EdTech / Knowledge Management** space with **Medium complexity**:

- No regulatory requirements (HIPAA, PCI-DSS)
- Standard security practices sufficient (no PII beyond email/password)
- Focus on user experience and AI accuracy over compliance
- Student privacy considerations minimal (no COPPA — targeting adults)

---

## Success Criteria

### User Success

**Core Success Metric:** Users can ask a question about their uploaded documents and receive an accurate, cited answer within 5 seconds.

| Metric | Target | Measurement |
| --- | --- | --- |
| **Answer Accuracy** | 90%+ relevance | AI retrieves correct context for query |
| **Source Citation** | 100% of responses | Every answer includes document + page reference |
| **Response Time** | < 5 seconds | From query submit to answer displayed |
| **First-Time Success** | 80%+ | Users get useful answer on first try |

**User Delight Moments:**

1. **Upload Confidence:** User uploads a 50-page contract, sees "Processing complete" — feels relief that they don't have to read it
2. **Magic Moment:** User asks "What's the termination clause?" and gets the exact answer with page citation in seconds
3. **Trust Builder:** User verifies cited source and confirms the AI got it right — builds confidence to rely on the system

### Business Success

**Primary Metric:** Create a deployable, demo-ready RAG application that generates client inquiries.

| Metric | Target | Timeframe |
| --- | --- | --- |
| **Portfolio Demo** | 1 polished 30-sec video | By launch |
| **GitHub Showcase** | Complete README with architecture diagram | By launch |
| **Code Reusability** | 70%+ code reusable for client projects | Ongoing |
| **Client Interest** | At least 1 inquiry from portfolio | Within 30 days of posting |

**3-Month Success:**

- Demo video views and engagement on portfolio
- At least one potential client mentions BrainVault as reason for inquiry

**12-Month Success:**

- Reused BrainVault codebase for 2+ paying client projects
- Reduced client RAG project delivery time by 50%

### Technical Success

| Metric | Target | Rationale |
| --- | --- | --- |
| **Uptime** | 99% availability | Free tier allows occasional cold starts |
| **Upload Success Rate** | 100% (zero-crash) | Files under 5MB must always process |
| **PDF Parse Accuracy** | 95%+ text extraction | Most standard PDFs should work |
| **Vector Retrieval** | Top-3 chunks relevant | RAG must find correct context |
| **LLM Grounding** | 0% hallucination outside context | Strict system prompt enforced |
| **Provider Flexibility** | Swap LLM in < 1 hour | Config-based switching works |

### Measurable Outcomes

**Demo Day Checklist (Definition of Done):**

- [ ] User can sign up / log in (email/password or guest)
- [ ] User can upload PDF (max 5MB) without crash
- [ ] System shows processing indicator during ingestion
- [ ] User can see list of uploaded documents
- [ ] User can enter chat interface for a document
- [ ] User can ask natural language question
- [ ] AI returns answer with source citation (document + page)
- [ ] Chat history persists per document/session
- [ ] 30-second demo video recorded and polished
- [ ] README with architecture diagram published

---

## Product Scope

### MVP - Minimum Viable Product (Week 1 Target)

**Must Have — Without these, the product is not demonstrable:**

| Feature | Description | Priority |
| --- | --- | --- |
| **Auth** | Email/Password + Guest login via Firebase | P0 |
| **PDF Upload** | Single PDF upload (max 5MB), text extraction | P0 |
| **Ingestion Pipeline** | Parse → Chunk → Embed → Store in Pinecone | P0 |
| **Chat Interface** | Natural language query input | P0 |
| **RAG Retrieval** | Top-3 chunk retrieval + LLM response | P0 |
| **Source Citation** | Display "Source: Document, Page X" | P0 |
| **Document List** | View all uploaded documents | P0 |
| **Chat History** | Persist conversation per document | P0 |

**MVP Tech Stack (Locked In):**

- Flutter + Provider/Riverpod
- Node.js + Express + TypeScript
- LangChain.js
- Pinecone (Free Tier)
- Firebase (Auth + Firestore + Storage)
- Gemini API (Free Tier preferred)

### Growth Features (Post-MVP)

**Nice to Have — Enhances demo impressiveness:**

| Feature | Description | Priority |
| --- | --- | --- |
| **Text Notes** | Paste raw text as knowledge source | P1 |
| **Web Links** | Ingest content from URLs | P1 |
| **Multi-Document Query** | Query across all documents at once | P1 |
| **Folder Organization** | Group documents into folders | P2 |
| **Highlight Source** | Navigate to exact location in PDF viewer | P2 |
| **Export Chat** | Download conversation as markdown | P2 |

### Vision (Future)

**Dream Features — Not for MVP, but could impress enterprise clients:**

| Feature | Description |
| --- | --- |
| **Team Workspaces** | Shared knowledge bases for organizations |
| **Custom AI Agents** | Domain-specific assistants (Legal, Medical, HR) |
| **OCR Support** | Handle scanned PDFs and images |
| **Voice Query** | Ask questions via voice input |
| **Slack/Teams Integration** | Query knowledge base from chat tools |
| **Analytics Dashboard** | Track most-queried documents and topics |

---

## User Journeys

### Journey 1: Priya Sharma — The Overwhelmed Law Student

**Who She Is:**
Priya is a second-year law student drowning in case law. She has a 200-page contract law textbook, three Supreme Court case PDFs, and a final exam in two weeks. Traditionally, she spends hours highlighting and creating index cards, but she still can't remember which case established which precedent.

**The Old Way (Pain):**
Every study session, Priya opens five PDFs, uses Ctrl+F to search for keywords, and reads paragraphs hoping she lands on the right section. She often misses relevant passages because she doesn't know the exact term to search. By the time she finds an answer, she's exhausted and her confidence is shaky.

**Discovering BrainVault:**
Late one night, while searching for "better ways to study contracts," Priya discovers BrainVault. The promise of asking questions in plain English and getting cited answers feels almost too good to be true. She decides to try the free tier.

**The Journey:**

1. **Sign Up (2 min):** Priya creates an account with her university email. The clean Material Design interface feels premium and trustworthy.

2. **First Upload (3 min):** She taps the "+" button and selects her Contract Law textbook PDF (4.2MB). A soothing progress animation shows "Processing... Extracting text... Creating knowledge base." She watches, hopeful.

3. **Processing Complete:** The app shows "Document ready! Ask me anything." Priya feels a spark of excitement.

4. **First Question (Magic Moment):** She types: *"What is consideration in contract law?"*

5. **The Answer:** Within 4 seconds, BrainVault responds:
   > "Consideration is the value exchanged between parties in a contract. It can be money, goods, services, or a promise to act or refrain from acting. Both parties must provide consideration for a contract to be legally binding."
   >
   > **Source: Contract Law Fundamentals, Page 47**

   Priya's eyes widen. She taps the source chip, and the exact page reference is there. It's correct.

6. **Deep Dive:** She asks follow-up questions: *"What's the difference between executed and executory consideration?"* Each answer comes with precise citations. For the first time, she's having a conversation with her textbook.

7. **Study Session Transformation:** Over the next hour, Priya uploads her three case PDFs and asks: *"Which case established that past consideration is not valid?"* BrainVault retrieves the answer from the correct case file with the exact page.

**The Resolution:**
Priya aces her exam. She shares BrainVault with her study group. The app didn't just help her study—it changed how she approaches learning. She's now the person in class who always knows which case to cite.

**Journey Requirements Revealed:**

- FR-1: PDF upload with progress indication
- FR-2: Text extraction and processing
- FR-4: Natural language query interface
- FR-5: Source citation with page numbers
- FR-6: Chat history for follow-up questions
- NFR: Response time under 5 seconds

---

### Journey 2: Marcus Chen — The Contract Reviewer

**Who He Is:**
Marcus is a procurement manager at a mid-sized tech company. Every week, he reviews 5-10 vendor contracts, each 30-50 pages long. His job is to identify unfavorable terms: auto-renewal clauses, liability caps, termination penalties. Missing one clause can cost the company thousands.

**The Old Way (Pain):**
Marcus prints contracts, highlights with multiple colors, and creates a checklist in Excel. He often works late, paranoid he missed something. His eyes glaze over after the 20th page. He dreams of having a paralegal, but the budget isn't there.

**Discovering BrainVault:**
Marcus sees a LinkedIn post about "AI-powered contract review" and clicks through. The BrainVault demo video shows exactly what he needs: upload a contract, ask about termination fees, get an instant answer.

**The Journey:**

1. **Quick Setup (1 min):** Marcus uses Guest Login to test the app first. No commitment, no friction.

2. **Upload Test Contract (2 min):** He uploads a vendor agreement he's currently reviewing. The processing indicator keeps him engaged.

3. **Critical Question:** *"What are the termination clauses in this contract?"*

4. **Comprehensive Answer:**
   > "This contract contains the following termination provisions:
   > 1. **Termination for Convenience:** Either party may terminate with 90 days written notice (Section 8.1, Page 12)
   > 2. **Termination for Cause:** Immediate termination for material breach with 30-day cure period (Section 8.2, Page 12)
   > 3. **Auto-Renewal:** Contract auto-renews annually unless cancelled 60 days before renewal date (Section 9.3, Page 14)
   > 4. **Early Termination Fee:** 25% of remaining contract value (Section 8.4, Page 13)"
   >
   > **Sources: Vendor Agreement, Pages 12-14**

5. **The Save:** Marcus almost missed the auto-renewal clause buried on page 14. BrainVault found it instantly. He adds a calendar reminder 70 days before renewal.

6. **Conversion:** Impressed, Marcus creates a full account. He uploads all pending contracts and creates a systematic review process.

**The Resolution:**
Marcus reduces contract review time by 60%. He catches an unfavorable indemnification clause that would have made the company liable for unlimited damages. His manager is impressed; Marcus gets a raise. He becomes an internal advocate for AI-powered workflows.

**Journey Requirements Revealed:**

- Auth: Guest login option for frictionless trial
- FR-1: Quick upload with clear progress
- FR-5: Multi-source answers citing multiple pages
- UI: Response formatting with structured answers
- Trust: Accurate citations users can verify

---

### Journey 3: Dr. Amara Okafor — The Research Academic

**Who She Is:**
Dr. Okafor is a biomedical researcher compiling a literature review for a grant proposal. She has 40+ research papers saved across folders, and she needs to find connections between studies that support her hypothesis. Manually cross-referencing papers takes weeks.

**The Old Way (Pain):**
Dr. Okafor uses Zotero for citations but still reads papers manually. She creates color-coded spreadsheets linking concepts across studies. The process is exhausting, and she often forgets which paper mentioned a specific finding.

**Discovering BrainVault:**
A colleague mentions using "AI to query research papers." Skeptical but curious, Dr. Okafor tries BrainVault with a subset of her papers.

**The Journey:**

1. **Strategic Upload:** She uploads 10 key papers related to her research topic (each under 5MB).

2. **Cross-Paper Question:** *"Which studies found a correlation between biomarker X and patient outcomes?"*

3. **Literature Synthesis:**
   > "Based on the uploaded documents, the following studies found correlations:
   > 1. Smith et al. (2023) found significant correlation (p<0.05) in cohort of 500 patients (Paper: biomarker-study-2023.pdf, Page 8)
   > 2. Johnson et al. (2022) reported moderate correlation in pediatric population (Paper: pediatric-markers.pdf, Page 12)
   > 3. Lee et al. (2024) noted correlation diminishes with age >65 (Paper: aging-biomarkers.pdf, Page 15)"

4. **Grant Proposal Accelerated:** Instead of weeks, Dr. Okafor completes her literature review in days. The citations are ready for her proposal.

**The Resolution:**
Dr. Okafor's grant proposal is funded. She acknowledges BrainVault as a productivity tool in her lab's workflow. She recommends it to graduate students.

**Journey Requirements Revealed:**

- Scalability: Handle multiple documents per user
- FR-5: Cross-document retrieval (Growth Feature)
- Citation format: Useful for academic workflows
- Accuracy: Critical for research trust

---

### Journey 4: Alex Rivera — The Error Recovery User

**Who They Are:**
Alex is a freelance consultant who tries to upload a scanned PDF (image-based, no text layer). The upload succeeds, but the AI can't find relevant content because there's no extractable text.

**The Journey:**

1. **Upload Attempt:** Alex uploads a scanned contract (3MB PDF, but it's essentially an image).

2. **Processing Complete:** App shows "Document ready!" (false positive — no text extracted).

3. **Query Failure:** Alex asks: *"What's the payment schedule?"*

4. **Honest Response:**
   > "I couldn't find relevant information about payment schedules in this document. This may be because:
   > - The document contains scanned images without text
   > - The content uses different terminology
   >
   > **Tip:** For scanned documents, try using OCR software first, then re-upload the text version."

5. **Clear Guidance:** The error message is helpful, not frustrating. Alex understands the limitation and exports the PDF to text using another tool.

6. **Second Attempt Success:** Alex re-uploads the OCR'd version, and the query works perfectly.

**Journey Requirements Revealed:**

- Error handling: Graceful failure with helpful guidance
- NFR: Honest responses when information isn't found
- Edge case: Scanned PDF limitations clearly communicated
- Future: OCR support as Vision Feature

---

### Journey 5: Portfolio Demo Viewer — The Potential Client

**Who They Are:**
A business owner watching your portfolio demo video on your website. They have 2 minutes of attention.

**The Journey:**

1. **Video Opens (0:00-0:05):** Clean title card: "BrainVault — Chat with Your Documents"

2. **Problem Statement (0:05-0:10):** Text overlay: "Reading 50-page contracts? There's a better way."

3. **Upload Demo (0:10-0:15):** Screen recording shows PDF upload with sleek progress animation.

4. **Magic Question (0:15-0:22):** User types: "What's the termination fee?"

5. **Impressive Answer (0:22-0:28):** AI responds with structured answer + source citation. Viewer sees the value immediately.

6. **Call to Action (0:28-0:30):** "Want this for your business? Let's talk."

**The Resolution:**
The potential client clicks "Contact" and becomes a paying customer for a custom RAG implementation.

**Journey Requirements Revealed:**

- Demo quality: Smooth, polished UI for video recording
- Speed: Fast responses for impressive demo
- Visual: Clean Material Design 3 aesthetics
- Portfolio: README with architecture diagram

---

## Journey Requirements Summary

| Journey | Primary Requirements |
| --- | --- |
| **Priya (Student)** | PDF upload, NL query, source citations, chat history |
| **Marcus (Professional)** | Guest login, multi-source answers, formatted responses |
| **Dr. Okafor (Researcher)** | Multi-doc support (Growth), cross-document retrieval |
| **Alex (Error Case)** | Graceful error handling, clear limitations, recovery guidance |
| **Demo Viewer (Client)** | Polish, speed, visual appeal, portfolio presentation |

### User Type Coverage

| User Type | Journey | Status |
| --- | --- | --- |
| Primary User (Success) | Priya, Marcus, Dr. Okafor | ✅ Covered |
| Primary User (Edge Case) | Alex | ✅ Covered |
| Secondary User (Admin) | Not needed for MVP portfolio | ⏭️ Skip |
| Demo/Portfolio Viewer | Potential Client | ✅ Covered |

---

## Mobile App Specific Requirements

### Platform Overview

BrainVault is a cross-platform mobile application built with Flutter (Dart), targeting both iOS and Android from a single codebase. This approach maximizes development efficiency and ensures consistent user experience across platforms.

### Platform Requirements

| Requirement | iOS | Android |
| --- | --- | --- |
| **Minimum Version** | iOS 12.0+ | Android 6.0 (API 23+) |
| **Target Version** | iOS 17 | Android 14 (API 34) |
| **Framework** | Flutter 3.x | Flutter 3.x |
| **State Management** | Riverpod (preferred) or Provider | |
| **UI Library** | Material Design 3 | |

### Device Permissions

| Permission | Purpose | Required |
| --- | --- | --- |
| **Internet** | API calls to backend | ✅ Required |
| **Storage (Read)** | PDF file selection | ✅ Required |
| **Storage (Write)** | Cache chat history | ✅ Required |
| **Camera** | Future OCR capture | ⏭️ Optional (Growth) |

**Privacy Justification:**

- No location data collected
- No contacts accessed
- No microphone access
- Minimal permissions = higher store approval likelihood

### Offline Mode Strategy

| Feature | Offline Behavior |
| --- | --- |
| **Document List** | ✅ Cached locally, viewable offline |
| **Chat History** | ✅ Cached locally, viewable offline |
| **New Queries** | ❌ Requires network (LLM API) |
| **PDF Upload** | ❌ Requires network (backend processing) |
| **Authentication** | ⚠️ Cached tokens, refresh on reconnect |

**Implementation:**

- Use SQLite or Hive for local persistence
- Dio interceptor for network state handling
- Graceful "No connection" UI states
- Sync on reconnect

### Push Notification Strategy (Growth Feature)

| Notification Type | Priority | MVP Status |
| --- | --- | --- |
| **Processing Complete** | Medium | ⏭️ Post-MVP |
| **Weekly Digest** | Low | ⏭️ Vision |

**MVP Approach:** Polling-based status checks during upload. Push notifications deferred to Growth phase.

### Store Compliance

#### Android

| Requirement | Status |
| --- | --- |
| **APK Build** | ✅ Demo-ready |
| **Play Console Setup** | ⏭️ Optional |
| **Privacy Policy** | ✅ Required (simple template) |
| **Content Rating** | Everyone / Low maturity |

#### iOS

| Requirement | Status |
| --- | --- |
| **Simulator Screenshots** | ✅ Portfolio demo |
| **TestFlight** | ⏭️ Optional |
| **App Store Submission** | ⏭️ Not for MVP |
| **Privacy Nutrition Labels** | ✅ Required if App Store |

**Privacy Policy Template Needs:**

- What data is collected (email, document content)
- How data is stored (Firebase, Pinecone)
- Third-party services (Google Gemini API)
- Data deletion process (account deletion)

### Technical Architecture Considerations

#### Networking Layer

- **HTTP Client:** Dio (multipart upload support, interceptors)
- **File Upload:** Chunked upload for reliability
- **Timeout Handling:** 30s for uploads, 60s for AI responses
- **Retry Logic:** Exponential backoff for failed requests

#### State Management

- **Riverpod** (preferred): Type-safe, testable, scalable
- **Provider** (alternative): Simpler, well-documented

#### Local Storage

- **Hive:** Fast, lightweight for chat history cache
- **Secure Storage:** For auth tokens

#### Error Handling

- Global error boundary with user-friendly messages
- Crash reporting (Firebase Crashlytics)
- Network error recovery flows

### UI/UX Guidelines

| Guideline | Implementation |
| --- | --- |
| **Design System** | Material Design 3 |
| **Theme** | Light mode primary, dark mode support |
| **Typography** | Google Fonts (Inter or Roboto) |
| **Icons** | Material Symbols |
| **Loading States** | Skeleton loaders, not spinners |
| **Animations** | Subtle, 200-300ms transitions |

### Implementation Considerations

| Aspect | Decision | Rationale |
| --- | --- | --- |
| **Screen Sizes** | Responsive, phone-first | Portfolio demo on mobile |
| **Orientation** | Portrait locked | Simplify MVP |
| **Accessibility** | Basic (semantic labels) | Best practice |
| **Localization** | English only MVP | Reduce scope |
| **Deep Linking** | Not required MVP | Skip complexity |

---

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Problem-Solving MVP with Portfolio Polish  
**Timeline:** 5 days (solo developer)  
**Resource Requirements:** 1 full-stack developer with Flutter, Node.js, and LangChain experience

**MVP Success Definition:**

The MVP succeeds when:

1. ✅ A user can upload a PDF and ask it questions
2. ✅ The AI returns accurate answers with source citations
3. ✅ The experience is smooth enough to record a 30-second demo video
4. ✅ The codebase is clean enough to reuse for client projects

### MVP Feature Set (Phase 1 - Week 1)

**Core User Journeys Supported:**

| Journey | MVP Coverage |
| --- | --- |
| Priya (Student) | ✅ Full support |
| Marcus (Professional) | ✅ Full support |
| Alex (Error Recovery) | ✅ Graceful handling |
| Demo Viewer | ✅ Polished for video |
| Dr. Okafor (Researcher) | ⚠️ Single-doc only (multi-doc is Growth) |

**Must-Have Capabilities (P0):**

| # | Feature | Rationale |
| --- | --- | --- |
| 1 | Firebase Auth (Email + Guest) | Gate access, demo flexibility |
| 2 | PDF Upload (max 5MB) | Core input method |
| 3 | Processing Pipeline (Parse → Chunk → Embed → Store) | Core RAG infra |
| 4 | Document List View | Navigation, basic UX |
| 5 | Chat Interface | Core interaction |
| 6 | RAG Query (Top-3 chunks → LLM → Response) | Core value |
| 7 | Source Citations (Document + Page) | Trust + differentiation |
| 8 | Chat History (per document) | Context, usability |
| 9 | Loading States (Skeleton loaders) | Polish for demo |
| 10 | Error Handling (Graceful failures) | Robustness |

**Explicitly OUT of MVP Scope (Deferred):**

| Feature | Why Deferred | Phase |
| --- | --- | --- |
| Text Notes (paste) | Nice-to-have, not core demo | Phase 2 |
| Web Link Ingestion | Additional complexity | Phase 2 |
| Multi-Document Query | Requires advanced RAG | Phase 2 |
| Folder Organization | UX enhancement | Phase 2 |
| Push Notifications | Infra overhead | Phase 3 |
| OCR for Scanned PDFs | Complex, external service | Phase 3 |
| Team Workspaces | Multi-tenant complexity | Vision |

### Post-MVP Features

## Phase 2: Growth (Week 2-3)

| Feature | User Value | Technical Complexity |
| --- | --- | --- |
| Text Notes | Flexibility in content ingestion | Low |
| Web Link Ingestion | Capture articles, docs | Medium |
| Multi-Document Query | Cross-reference knowledge | Medium-High |
| Dark Mode | User preference | Low |
| Improved Onboarding | First-run experience | Low |

## Phase 3: Expansion (Month 2+)

| Feature | User Value | Technical Complexity |
| --- | --- | --- |
| Folder Organization | Large document management | Low |
| Push Notifications | Async processing updates | Medium |
| PDF Viewer with Highlights | Navigate to cited source | High |
| Export Chat | Save conversations | Low |
| Voice Input | Accessibility, convenience | Medium |

### Vision (Future Post-MVP)

| Feature | Strategic Value |
| --- | --- |
| Team Workspaces | B2B expansion, revenue |
| Custom AI Agents | Domain-specific solutions |
| OCR Support | Scanned document handling |
| Slack/Teams Integration | Enterprise adoption |
| Analytics Dashboard | Usage insights |

### Development Timeline (5-Day Sprint)

| Day | Focus | Deliverables |
| --- | --- | --- |
| **Day 1** | Foundation | Project setup, Firebase Auth, UI skeleton |
| **Day 2** | Backend Core | Node.js setup, Pinecone connection, PDF upload endpoint |
| **Day 3** | AI Pipeline | LangChain integration, ingestion pipeline |
| **Day 4** | Chat Experience | Chat UI, RAG endpoint, source citations |
| **Day 5** | Polish & Demo | Error handling, loading states, demo video recording |

**Critical Path:**

1. Day 2 must complete Pinecone connection — blocks Day 3
2. Day 3 must complete ingestion — blocks Day 4 chat
3. Day 4 must complete citations — core demo feature

### Risk Mitigation Strategy

**Technical Risks:**

| Risk | Impact | Mitigation |
| --- | --- | --- |
| LLM Hallucination | High (broken demo) | Strict system prompt: "Answer ONLY from context" |
| Free Tier Latency | Medium (slow demo) | Skeleton loaders, optimize chunk size |
| PDF Parse Failures | Medium (broken flow) | Validate PDF on upload, clear error messages |
| Pinecone Free Tier Limits | Low | Single namespace, monitor usage |

**Market Risks:**

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Competition (ChatPDF, etc.) | Medium | Focus on portfolio value, not market competition |
| Low Client Interest | Low | Demo quality + clear architecture diagram |

**Resource Risks:**

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Time Overrun | High | Ruthless scope cuts, defer P1 features |
| API Key Exhaustion | Medium | Use Gemini free tier, monitor usage |
| Burnout | Medium | Timebox each day, ship "good enough" |

### Scope Lock Statement

**This MVP scope is LOCKED for the 5-day sprint.**

Any feature not in the P0 list above is automatically deferred to Phase 2+. If a P0 feature is blocked, the team will escalate immediately, not add workarounds.

**Scope Negotiation Rules:**

- Adding any feature requires removing another of equal size
- "Nice-to-have" features are only discussed after MVP ships
- Demo quality is non-negotiable; missing features are acceptable

---

## Functional Requirements

### User Authentication & Access

| ID | Requirement |
| --- | --- |
| FR1 | Users can create an account using email and password |
| FR2 | Users can log in to an existing account using email and password |
| FR3 | Users can log out of their account |
| FR4 | Users can access the app as a guest without creating an account |
| FR5 | Guest users can convert their session to a full account |
| FR6 | Users can reset their password via email |

### Document Ingestion

| ID | Requirement |
| --- | --- |
| FR7 | Users can upload PDF documents from their device |
| FR8 | Users can see upload progress while a document is being processed |
| FR9 | System validates PDF files before processing (file type, size ≤5MB) |
| FR10 | System extracts text content from uploaded PDF documents |
| FR11 | System splits extracted text into semantic chunks for processing |
| FR12 | System generates vector embeddings for each text chunk |
| FR13 | System stores embeddings in a vector database associated with the document |
| FR14 | System stores document metadata (name, upload date, page count, user ID) |
| FR15 | Users receive confirmation when document processing is complete |
| FR16 | Users receive clear error messages if document processing fails |

### Document Management

| ID | Requirement |
| --- | --- |
| FR17 | Users can view a list of all their uploaded documents |
| FR18 | Users can see document metadata (name, upload date, page count) in the list |
| FR19 | Users can delete documents they have uploaded |
| FR20 | Users can select a document to begin a chat conversation |

### Chat & Query Interface

| ID | Requirement |
| --- | --- |
| FR21 | Users can type natural language questions in a chat interface |
| FR22 | Users can send their question to the AI for processing |
| FR23 | Users can see a loading indicator while the AI processes their query |
| FR24 | System retrieves the most relevant text chunks for the user's query |
| FR25 | System passes retrieved context and query to the LLM for response generation |
| FR26 | System displays the AI-generated response in the chat interface |
| FR27 | Users can see source citations (document name, page number) with each response |
| FR28 | Users can ask follow-up questions in the same chat session |
| FR29 | System maintains conversation context within a chat session |

### Chat History & Persistence

| ID | Requirement |
| --- | --- |
| FR30 | System persists chat history for each document |
| FR31 | Users can view previous chat conversations for a document |
| FR32 | Users can continue a previous chat conversation |
| FR33 | Users can clear chat history for a document |
| FR34 | Chat history is cached locally for offline viewing |

### Error Handling & Edge Cases

| ID | Requirement |
| --- | --- |
| FR35 | System displays helpful guidance when no relevant content is found |
| FR36 | System informs users of limitations (e.g., scanned PDFs without text layer) |
| FR37 | System handles network connectivity issues gracefully |
| FR38 | System displays appropriate error messages for all failure scenarios |

### AI Response Quality

| ID | Requirement |
| --- | --- |
| FR39 | AI responds only based on content from the user's uploaded documents |
| FR40 | AI indicates when it cannot find relevant information in the document |
| FR41 | AI provides honest "I don't know" responses rather than hallucinating |

### Capability Summary

| Capability Area | FR Count | MVP Priority |
| --- | --- | --- |
| User Authentication | FR1-FR6 | P0 (Core) |
| Document Ingestion | FR7-FR16 | P0 (Core) |
| Document Management | FR17-FR20 | P0 (Core) |
| Chat & Query | FR21-FR29 | P0 (Core) |
| Chat History | FR30-FR34 | P0 (Core) |
| Error Handling | FR35-FR38 | P0 (Core) |
| AI Response Quality | FR39-FR41 | P0 (Core) |

**Total Functional Requirements:** 41

### Future Capability Areas (Not in MVP)

The following capability areas are documented for future phases but have NO FRs in MVP:

| Capability Area | Phase | Notes |
| --- | --- | --- |
| Text Note Ingestion | Phase 2 | Paste raw text as knowledge source |
| Web Link Ingestion | Phase 2 | Ingest content from URLs |
| Multi-Document Query | Phase 2 | Query across all documents |
| Folder Organization | Phase 3 | Group documents into folders |
| Push Notifications | Phase 3 | Async processing updates |
| Team Workspaces | Vision | Multi-user shared knowledge |
| OCR Support | Vision | Scanned document handling |

---

## Non-Functional Requirements

### Performance

| ID | Requirement | Target | Measurement |
| --- | --- | --- | --- |
| NFR1 | Query response time (end-to-end) | < 5 seconds | Time from send to response displayed |
| NFR2 | Document upload time (≤5MB) | < 30 seconds | Time from upload start to "processing" state |
| NFR3 | PDF text extraction time | < 10 seconds | Time to parse PDF and extract text |
| NFR4 | Vector embedding generation | < 15 seconds | Time to generate all chunk embeddings |
| NFR5 | App launch time (cold start) | < 3 seconds | Time to interactive home screen |
| NFR6 | Chat interface input latency | < 100ms | Time from keypress to character display |

**Performance Context:**

- Free tier services (Render, Pinecone, Gemini) may have cold start latency
- Skeleton loaders and optimistic UI updates mitigate perceived latency
- Large documents (50+ pages) may exceed targets — acceptable for MVP

### Security

| ID | Requirement | Target | Implementation Guidance |
| --- | --- | --- | --- |
| NFR7 | API keys must not be exposed in client code | 0 keys in app | All API keys stored server-side in environment variables |
| NFR8 | User authentication tokens secured | Encrypted storage | Use Flutter Secure Storage for auth tokens |
| NFR9 | Data in transit encrypted | HTTPS only | All API calls over TLS 1.2+ |
| NFR10 | User data isolation | Per-user segregation | Documents and chats scoped to authenticated user ID |
| NFR11 | Password storage | Hashed with salt | Firebase Auth handles (no custom implementation) |
| NFR12 | Guest user data handling | Ephemeral or convertible | Guest data can be claimed by account creation |

**Security Context:**

- No PCI-DSS requirements (no payments)
- No HIPAA requirements (not handling medical data)
- No GDPR-specific requirements for MVP (but good practice to support data deletion)
- API key protection is critical — exposure would allow abuse

### Reliability

| ID | Requirement | Target | Measurement |
| --- | --- | --- | --- |
| NFR13 | System availability | 99% uptime | Monthly uptime calculation |
| NFR14 | PDF upload success rate | 100% for valid files | Zero crashes for files ≤5MB, valid PDFs |
| NFR15 | Graceful degradation | Informative errors | All failure scenarios have user-friendly messages |
| NFR16 | Data persistence | No data loss | Uploaded documents and chat history survive restarts |
| NFR17 | Network failure recovery | Auto-retry | Failed API calls retry with exponential backoff |

**Reliability Context:**

- Free tier hosting (Render) may have cold starts and scheduled downtime
- 99% uptime = ~7 hours downtime/month — acceptable for portfolio
- "Zero-crash" is explicit success criteria from brief

### Usability

| ID | Requirement | Target | Measurement |
| --- | --- | --- | --- |
| NFR18 | First-time user success | Complete core flow in < 5 min | Time from signup to first successful query |
| NFR19 | Loading state visibility | 100% coverage | All async operations show loading indicators |
| NFR20 | Error message clarity | Actionable guidance | Every error includes what to do next |
| NFR21 | Interface consistency | Material Design 3 | Consistent components across all screens |
| NFR22 | Mobile responsiveness | Works on all screen sizes | Tested on phones 5"-7" screen sizes |

**Usability Context:**

- Portfolio demo requires polished, professional UX
- Skeleton loaders preferred over spinners for perceived performance
- Error messages should guide users to success, not just report failures

### Accessibility (Basic)

| ID | Requirement | Target | Scope |
| --- | --- | --- | --- |
| NFR23 | Semantic labels | All interactive elements | Screen reader support for buttons, inputs |
| NFR24 | Text contrast | WCAG AA (4.5:1) | Readable text in both light and dark themes |
| NFR25 | Touch targets | 44x44dp minimum | All tappable areas meet minimum size |

**Accessibility Context:**

- Basic accessibility is best practice, not primary focus
- No legal requirements for portfolio project
- Support for screen readers is minimal implementation

### Maintainability

| ID | Requirement | Target | Measurement |
| --- | --- | --- | --- |
| NFR26 | Code reusability | 70%+ reusable for client projects | Modular architecture, clear separation of concerns |
| NFR27 | LLM provider flexibility | Swap in < 1 hour | Config-based provider switching (Gemini ↔ Llama via Replicate) |
| NFR28 | Documentation | README with architecture diagram | Developer onboarding in < 30 minutes |
| NFR29 | Code structure | Clean architecture patterns | Separation of UI, business logic, data layers |

**Maintainability Context:**

- Explicit business goal: "Create reusable RAG boilerplate"
- Future client projects will clone and adapt this codebase
- Architecture diagram is required for portfolio presentation

### Scalability (Future Considerations)

| ID | Requirement | Target | MVP Status |
| --- | --- | --- | --- |
| NFR30 | User capacity | 100 concurrent users | Not tested for MVP, document for future |
| NFR31 | Document storage | 1000 documents per user | Architectural limit, not enforced in MVP |
| NFR32 | Horizontal scaling | Stateless backend | Design allows scaling, not tested |

**Scalability Context:**

- Portfolio project, not expecting high traffic
- Stateless backend design allows future horizontal scaling
- Free tier limits will constrain before scale becomes issue

### NFR Summary Matrix

| Category | Critical for MVP | Success Metric |
| --- | --- | --- |
| Performance | ✅ Yes | < 5s query response |
| Security | ✅ Yes | 0 API keys exposed |
| Reliability | ✅ Yes | 100% upload success |
| Usability | ✅ Yes | Polished demo quality |
| Accessibility | ⚠️ Basic | Semantic labels only |
| Maintainability | ✅ Yes | 70%+ code reuse |
| Scalability | ⏭️ Deferred | Future consideration |
