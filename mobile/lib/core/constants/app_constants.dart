/// App-wide constants
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3001/api';

  // Firebase
  static const String projectName = 'brainvault';
  static const String organization = 'com.avishkagihan';

  // Constraints
  static const int minTouchTarget = 48; // Material Design 3 minimum
  static const double maxWidth = 600; // For responsive design

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Cache Keys
  static const String cachedDocumentsKey = 'cached_documents';
  static const String userAuthTokenKey = 'user_auth_token';
  static const String userEmailKey = 'user_email';

  // Feature Flags
  static const bool enableGuestMode = true;
  static const bool enableDarkMode = true;
}
