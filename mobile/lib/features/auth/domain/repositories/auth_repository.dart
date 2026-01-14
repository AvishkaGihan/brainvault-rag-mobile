import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in anonymously to Firebase
  /// Throws [Exception] if authentication fails
  Future<User> signInAsGuest();

  /// Register with email and password
  /// Throws [Exception] if registration fails
  Future<User> registerWithEmail(String email, String password);

  /// Sign in with email and password
  /// Throws [Exception] if authentication fails
  Future<User> signInWithEmail(String email, String password);

  /// Get the current authenticated user
  /// Returns null if no user is authenticated
  User? getCurrentUser();

  /// Stream of authentication state changes
  /// Emits null when user is signed out, User object when signed in
  Stream<User?> authStateChanges();

  /// Sign out the current user
  Future<void> signOut();
}
