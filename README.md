# BrainVault 🧠

[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Pinecone](https://img.shields.io/badge/Pinecone-000000?style=flat&logo=pinecone&logoColor=white)](https://www.pinecone.io/)

An AI-powered "Second Brain" mobile application that enables users to upload documents (PDFs, text notes) and engage in natural language conversations with their content using Retrieval-Augmented Generation (RAG). Built as a portfolio project and reusable RAG boilerplate.

## ✨ Features

- 📄 **Document Upload**: Seamlessly upload PDF documents and text notes
- 🤖 **AI-Powered Q&A**: Ask questions about your documents and get accurate, citation-backed answers
- 📚 **Source Attribution**: Every answer includes source citations showing exactly where information came from
- 🔒 **Privacy-First**: User data stays within their personal knowledge vault
- 📱 **Cross-Platform**: Available on iOS and Android
- 🔄 **Real-time Sync**: Synchronized across devices with Firebase

## 🛠️ Tech Stack

### Mobile App (Flutter)

- **Framework**: Flutter
- **Authentication**: Firebase Authentication
- **State Management**: Riverpod
- **Navigation**: Go Router
- **File Handling**: File Picker

### Backend (Node.js/TypeScript)

- **Runtime**: Node.js with Express.js
- **Authentication**: Firebase Admin SDK
- **Vector Database**: Pinecone
- **AI Model**: Google Gemini AI
- **RAG Framework**: LangChain
- **File Processing**: Multer, pdf-parse

## 📋 Prerequisites

- Flutter SDK (3.10.1+)
- Node.js (18+)
- Firebase project with Authentication and Firestore enabled
- Pinecone account and vector index
- Google AI API key (for Gemini)

## 🚀 Setup

### Backend Setup

1. **Navigate to backend directory**:

   ```bash
   cd backend
   ```

2. **Install dependencies**:

   ```bash
   npm install
   ```

3. **Configure environment**:
   Create a `.env` file in the backend directory:

   ```env
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_PRIVATE_KEY=your_private_key
   FIREBASE_CLIENT_EMAIL=your_client_email
   PINECONE_API_KEY=your_pinecone_api_key
   PINECONE_INDEX=your_index_name
   GOOGLE_API_KEY=your_google_api_key
   PORT=3000
   ```

4. **Start the server**:
   - Production: `npm run build && npm start`
   - Development: `npm run dev`

### Mobile App Setup

1. **Navigate to mobile directory**:

   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update `lib/firebase_options.dart` if necessary

4. **Generate assets**:

   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## 📖 Usage

1. **Register/Login**: Create an account or sign in with Firebase Authentication
2. **Upload Documents**: Add PDF files or paste text notes
3. **Ask Questions**: Query your documents in natural language
4. **Get Answers**: Receive AI-generated responses with source citations

## 🔌 API Endpoints

| Method | Endpoint                | Description                   |
| ------ | ----------------------- | ----------------------------- |
| POST   | `/api/auth/login`       | User authentication           |
| POST   | `/api/documents/upload` | Upload documents              |
| POST   | `/api/chat/ask`         | Ask questions about documents |
| GET    | `/api/documents`        | List user's documents         |
| DELETE | `/api/documents/:id`    | Delete a document             |

## 📁 Project Structure

```
brainvault-rag-mobile/
├── 📱 mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── 🏗️ app/            # App-level code
│   │   ├── ⚙️ core/           # Core functionality
│   │   ├── 🎯 features/       # Feature modules
│   │   ├── 🔗 shared/         # Shared components
│   │   └── firebase_options.dart
│   ├── android/               # Android-specific code
│   ├── ios/                   # iOS-specific code
│   └── pubspec.yaml
├── 🖥️ backend/                 # Node.js backend
│   ├── src/
│   │   ├── 🔧 config/         # Configuration files
│   │   ├── 🎮 controllers/    # Route handlers
│   │   ├── 🛡️ middleware/     # Express middleware
│   │   ├── 🛤️ routes/         # API routes
│   │   ├── 🔧 services/       # Business logic
│   │   ├── 📝 types/          # TypeScript types
│   │   └── 🛠️ utils/          # Utility functions
│   ├── package.json
│   └── tsconfig.json
├── 📚 docs/                   # Documentation
└── 🧠 _bmad/                  # Project management files
```

## 🤝 Contributing

This project serves as a portfolio demonstration and reusable RAG boilerplate. Contributions are welcome!

Please read our [Contributing Guide](CONTRIBUTING.md) for detailed instructions.

- 🐛 **Bug Reports**: Open an issue
- 💡 **Feature Requests**: Suggest new ideas
- 🔧 **Pull Requests**: Submit improvements

We also follow a [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a positive community.

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

For questions or feedback, please reach out to the project maintainer.

---

_Built with ❤️ using Flutter, Node.js, and cutting-edge AI technologies._
