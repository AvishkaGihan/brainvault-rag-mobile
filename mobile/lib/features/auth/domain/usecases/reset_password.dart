import '../repositories/auth_repository.dart';

/// Use case for sending password reset email
///
/// This use case handles the password reset flow:
/// 1. Validates email format (caller responsibility)
/// 2. Calls Firebase to send reset email
/// 3. Returns success result regardless of email existence (security)
///
/// Note: Firebase doesn't reveal if an email exists, preventing enumeration attacks.
class ResetPasswordUseCase {
  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  /// Send password reset email to the provided email address
  ///
  /// Always returns success to prevent email enumeration.
  /// Actual email is only sent if email exists in Firebase.
  ///
  /// Throws [Exception] on network errors or rate limits.
  Future<void> call(String email) async {
    await authRepository.sendPasswordResetEmail(email);
  }
}
