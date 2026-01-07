# BrainVault - Mobile App

BrainVault is a Flutter-based mobile application that allows users to chat with their PDF documents using AI-powered RAG (Retrieval-Augmented Generation).

## Prerequisites

Before running the BrainVault mobile app, ensure you have the following installed:

- **Flutter SDK**: Version 3.10.1 or higher
  - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Version 3.10.1 or higher (comes with Flutter)
- **Android SDK**: API level 21 (Android 5.0) or higher
  - [Android Setup Guide](https://flutter.dev/docs/get-started/install/windows#android-setup)
- **Xcode**: For iOS development (macOS only)
  - Version 14.0 or higher recommended
- **CocoaPods**: For iOS dependency management (macOS only)
  - Install with: `sudo gem install cocoapods`

## Environment Setup

### Check Your Environment

Run the following command to verify your Flutter setup:

```bash
flutter doctor
```

This should show all green checkmarks ✓ for the tools you need.

## Installation Steps

### 1. Install Dependencies

Navigate to the `mobile` directory and fetch all Dart dependencies:

```bash
cd mobile
flutter pub get
```

### 2. iOS Setup (macOS Only)

For iOS development, also run:

```bash
cd ios
pod install
cd ..
```

### 3. Android Setup

Ensure your Android environment is configured:

```bash
flutter doctor -v
```

Check that Android SDK, Android Studio, and Connected Devices are properly configured.

## Running the App

### On Android Emulator

1. Start an Android emulator:

   ```bash
   emulator @<emulator-name>
   ```

   Or use Android Studio to launch an emulator.

2. Run the app:
   ```bash
   flutter run
   ```

### On iOS Simulator (macOS)

1. Start the iOS simulator:

   ```bash
   open -a Simulator
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### On Physical Device

1. Connect your Android device via USB with USB Debugging enabled
2. Run:
   ```bash
   flutter run
   ```

## Project Structure Overview

```
mobile/lib/
├── main.dart                    # App entry point
├── app/
│   ├── app.dart                 # MaterialApp configuration with theme
│   └── routes.dart              # GoRouter navigation setup
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
├── core/                        # Shared functionality
│   ├── constants/               # App-wide constants
│   ├── network/                 # Dio HTTP client setup
│   ├── theme/                   # Material Design 3 theme
│   ├── cache/                   # Local caching logic
│   ├── error/                   # Error handling
│   └── utils/                   # Utilities and helpers
└── shared/
    └── widgets/                 # Reusable UI components
```

## Architecture

BrainVault uses a **Clean Architecture** pattern with the following layers:

- **Presentation**: UI screens, widgets, and Riverpod state management
- **Domain**: Business logic, entities, and use cases
- **Data**: Repositories, data sources, and API interactions

## State Management

The app uses **Flutter Riverpod** for state management with AsyncValue for handling async operations:

```dart
final documentsProvider = FutureProvider<List<Document>>((ref) async {
  // Fetch documents from repository
});
```

## Dependencies

Key dependencies in this project:

- **flutter_riverpod**: State management
- **go_router**: Navigation and routing
- **dio**: HTTP client for API communication
- **firebase_core & firebase_auth**: Firebase integration
- **file_picker**: Document selection from device
- **shared_preferences**: Local caching

For the complete list, see `pubspec.yaml`.

## Theme Configuration

The app uses **Material Design 3** with the following brand colors:

- **Primary**: #6750A4 (Deep Purple)
- **Tertiary**: #7D5260 (Dusty Rose) - for source citations
- **8dp spacing unit** for consistent layout

The theme supports both light and dark modes automatically based on system settings.

## Development Commands

### Code Analysis

Check code quality and potential errors:

```bash
flutter analyze
```

### Running Tests

Run all unit and widget tests:

```bash
flutter test
```

### Code Generation

If using Riverpod's code generation:

```bash
dart run build_runner build
```

## Firebase Setup (Placeholder)

Firebase setup will be configured during authentication implementation. The `firebase_options.dart` file has been pre-generated but requires Firebase console setup.

**Configuration required:**

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Add Android and iOS apps to the project
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Initialize Firebase in `main.dart`

## Platform-Specific Notes

### Android

- Minimum SDK Version: 21 (Android 5.0)
- Target SDK Version: 34 (Android 14)
- Application ID: `com.avishkagihan.brainvault`

### iOS

- Minimum Deployment Target: iOS 12.0
- Bundle Identifier: `com.avishkagihan.brainvault`

## Troubleshooting

### Common Issues

**"flutter: command not found"**

- Ensure Flutter is in your PATH. See [Flutter Installation](https://flutter.dev/docs/get-started/install)

**Android emulator not found**

- Create an emulator in Android Studio or run: `flutter emulators --launch <id>`

**Pod install fails (iOS)**

- Try: `rm ios/Podfile.lock` and then `flutter pub get`

**Build fails with dependency errors**

- Run: `flutter clean && flutter pub get`

## Continuous Development

### Hot Reload

During development, use hot reload to see changes instantly:

```bash
r          # Hot reload
R          # Hot restart
q          # Quit
```

### Code Formatting

Format code to match project style:

```bash
dart format lib/
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3 Guide](https://m3.material.io/)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture)

## Contributing

When adding new features:

1. Follow the Clean Architecture structure
2. Use Riverpod for state management
3. Add comprehensive tests
4. Update this README if adding new setup steps

## License

This project is part of the BrainVault portfolio project.

---

**Project Initialized**: January 6, 2026
**Framework**: Flutter 3.10.1+
**Minimum Android Version**: API 21
**Minimum iOS Version**: 12.0
