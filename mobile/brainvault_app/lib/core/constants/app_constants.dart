class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // File Upload Limits
  static const int maxFileSizeMB = 5;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024; // 5 MB
  static const List<String> allowedFileTypes = ['.pdf'];

  // Auth Validation Rules
  static const int minPasswordLength = 6;
  // Simple but effective email regex standard for mobile input validation
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+",
  );

  // Chat Validation
  static const int maxMessageLength = 1000;
  static const int minMessageLength = 1;

  // Processing & UI Configuration
  static const Duration pollingInterval = Duration(seconds: 2);
  static const Duration defaultCacheDuration = Duration(minutes: 10);
  static const Duration splashDuration = Duration(seconds: 2);

  // UI Labels for Processing Stages (Keys match backend status enums)
  static const Map<String, String> processingStageLabels = {
    'pending': 'Pending',
    'uploading': 'Uploading...',
    'processing': 'Processing PDF...',
    'embedding': 'Generating Embeddings...',
    'completed': 'Ready',
    'failed': 'Failed',
  };
}
