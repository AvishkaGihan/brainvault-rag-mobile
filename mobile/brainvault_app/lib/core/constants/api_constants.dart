class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // Base URL Configuration
  // Can be overridden at build time using: --dart-define=API_BASE_URL=https://api.example.com/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  // API Endpoints
  static const String authVerifyPath = '/auth/verify';
  static const String documentsPath = '/documents';
  static const String chatPath = '/chat';
  static const String statusPath = '/status';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Extended timeout specifically for LLM queries which can take longer
  static const Duration queryTimeout = Duration(seconds: 60);

  // HTTP Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
