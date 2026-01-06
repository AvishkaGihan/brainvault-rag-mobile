# BrainVault

An AI-powered "Second Brain" mobile application that enables users to upload documents (PDFs, text notes) and engage in natural language conversations with their content using Retrieval-Augmented Generation (RAG).

## Features

- **Document Upload**: Upload PDF documents and text notes
- **AI-Powered Q&A**: Ask questions about your documents and get accurate, citation-backed answers
- **Source Attribution**: Every answer includes source citations showing exactly where information came from
- **Privacy-First**: User data stays within their personal knowledge vault
- **Cross-Platform**: Available on iOS and Android

## Tech Stack

### Mobile App (Flutter)

- Flutter
- Firebase Authentication
- Riverpod for state management
- Go Router for navigation
- File Picker for document uploads

### Backend (Node.js/TypeScript)

- Express.js
- Firebase Admin SDK
- Pinecone for vector search
- Google Gemini AI
- LangChain for RAG implementation
- Multer for file uploads
- PDF parsing with pdf-parse

## Prerequisites

- Flutter SDK (3.10.1+)
- Node.js (18+)
- Firebase project with Authentication and Firestore enabled
- Pinecone account and index
- Google AI API key

## Setup

### Backend Setup

1. Navigate to the backend directory:

   ```bash
   cd backend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Create a `.env` file with the following variables:

   ```
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_PRIVATE_KEY=your_private_key
   FIREBASE_CLIENT_EMAIL=your_client_email
   PINECONE_API_KEY=your_pinecone_api_key
   PINECONE_INDEX=your_index_name
   GOOGLE_API_KEY=your_google_api_key
   PORT=3000
   ```

4. Build and start the server:

   ```bash
   npm run build
   npm start
   ```

   Or for development:

   ```bash
   npm run dev
   ```

### Mobile App Setup

1. Navigate to the mobile directory:

   ```bash
   cd mobile
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories
   - Update `lib/firebase_options.dart` if needed

4. Generate app icons and splash screen:

   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Register/Login with Firebase Authentication
2. Upload PDF documents or text notes
3. Ask questions about your documents in natural language
4. Receive AI-generated answers with source citations

## API Endpoints

- `POST /api/auth/login` - User authentication
- `POST /api/documents/upload` - Upload documents
- `POST /api/chat/ask` - Ask questions about documents
- `GET /api/documents` - List user's documents

## Project Structure

```
brainvault-rag-mobile/
├── backend/                 # Node.js backend
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── controllers/    # Route handlers
│   │   ├── middleware/     # Express middleware
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── types/          # TypeScript types
│   │   └── utils/          # Utility functions
│   ├── package.json
│   └── tsconfig.json
├── mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── app/            # App-level code
│   │   ├── core/           # Core functionality
│   │   ├── features/       # Feature modules
│   │   ├── shared/         # Shared components
│   │   └── firebase_options.dart
│   ├── android/            # Android-specific code
│   ├── ios/                # iOS-specific code
│   └── pubspec.yaml
├── docs/                   # Documentation
└── _bmad/                  # Project management files
```

## Contributing

This project serves as a portfolio demonstration and reusable RAG boilerplate. Contributions are welcome for improvements and bug fixes.

## License

ISC License

## Contact

For questions or feedback, please reach out to the project maintainer.</content>
<parameter name="filePath">c:\Users\avish\OneDrive\Documents\Projects\brainvault-rag-mobile\README.md
