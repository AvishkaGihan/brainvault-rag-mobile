class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  // Hive Box Names
  // Used for non-sensitive local data persistence
  static const String documentsBox = 'documents';
  static const String messagesBox = 'messages';
  static const String settingsBox = 'settings';

  // Secure Storage Keys
  // Used for sensitive data via FlutterSecureStorage
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // Shared Preferences Keys
  // Used for simple user settings and lightweight state
  static const String themeModeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync_timestamp';
}
