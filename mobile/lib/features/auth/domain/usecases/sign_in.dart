import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
///
/// This use case handles the login flow for existing users:
/// 1. Receives email and password from the presentation layer
/// 2. Delegates to the auth repository's signInWithEmail method
/// 3. Returns the authenticated User entity on success
/// 4. Propagates typed exceptions (AuthException, NetworkException, etc.) to caller
///
/// Follows the Single Responsibility Principle: only orchestrates the login operation
/// without handling UI state or error transformation (that's the presenter's job).
class SignInUseCase {
  final AuthRepository authRepository;

  SignInUseCase({required this.authRepository});

  /// Execute the email/password login operation
  ///
  /// Calls the repository's signInWithEmail method with provided credentials.
  /// The repository is responsible for:
  /// - Calling Firebase Auth's signInWithEmailAndPassword
  /// - Mapping Firebase errors to domain-layer exceptions
  /// - Returning the authenticated User entity
  ///
  /// Returns the authenticated User on success
  /// Throws Exception if sign-in fails (auth error, network error, etc.)
  ///
  /// Parameters:
  /// - [email]: User's email address (should be trimmed by caller)
  /// - [password]: User's password (never logged for security)
  Future<User> call(String email, String password) {
    return authRepository.signInWithEmail(email, password);
  }
}
