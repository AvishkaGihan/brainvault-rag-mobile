/// Base class for all failures in the application
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Network-related failures
sealed class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends NetworkFailure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// Authentication-related failures
sealed class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([super.message = 'Email already in use']);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure([super.message = 'Session expired']);
}

/// Document-related failures
sealed class DocumentFailure extends Failure {
  const DocumentFailure(super.message);
}

class FileTooLargeFailure extends DocumentFailure {
  const FileTooLargeFailure([
    super.message = 'File too large. Maximum size is 5MB.',
  ]);
}

class InvalidFileTypeFailure extends DocumentFailure {
  const InvalidFileTypeFailure([
    super.message = 'Invalid file type. Only PDF files are supported.',
  ]);
}

class FilePickerCancelledFailure extends DocumentFailure {
  const FilePickerCancelledFailure([
    super.message = 'File selection cancelled',
  ]);
}

class DocumentNotFoundFailure extends DocumentFailure {
  const DocumentNotFoundFailure([super.message = 'Document not found']);
}

class DocumentUploadFailure extends DocumentFailure {
  const DocumentUploadFailure([super.message = 'Failed to upload document']);
}

/// Cache-related failures
sealed class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class CacheReadFailure extends CacheFailure {
  const CacheReadFailure([super.message = 'Failed to read from cache']);
}

class CacheWriteFailure extends CacheFailure {
  const CacheWriteFailure([super.message = 'Failed to write to cache']);
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
