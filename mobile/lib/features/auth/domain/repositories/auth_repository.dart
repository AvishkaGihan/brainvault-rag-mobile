import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in anonymously to Firebase
  /// Throws [Exception] if authentication fails
  Future<User> signInAsGuest();

  /// Get the current authenticated user
  /// Returns null if no user is authenticated
  User? getCurrentUser();

  /// Stream of authentication state changes
  /// Emits null when user is signed out, User object when signed in
  Stream<User?> authStateChanges();

  /// Sign out the current user
  Future<void> signOut();
}
