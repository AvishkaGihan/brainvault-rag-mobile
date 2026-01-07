/// API endpoint constants
class ApiConstants {
  // Base URL - will be configured via environment
  static const String baseUrl = 'http://localhost:3001/api';

  // Auth Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authPasswordReset = '/auth/password-reset';

  // Document Endpoints
  static const String documentsListUri = '/documents';
  static String documentDetailUri(String documentId) => '/documents/$documentId';
  static const String uploadDocument = '/documents/upload';
  static String deleteDocument(String documentId) => '/documents/$documentId';

  // Chat Endpoints
  static const String chatQueryUri = '/chat/query';
  static const String chatHistoryUri = '/chat/history';

  // Health Check
  static const String healthCheck = '/health';
}
