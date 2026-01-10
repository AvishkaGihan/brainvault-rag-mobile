import 'package:firebase_auth/firebase_auth.dart';

/// Exception thrown by auth data source
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Remote data source for Firebase authentication
abstract class AuthRemoteDataSource {
  /// Sign in anonymously to Firebase
  Future<UserCredential> signInAnonymously();

  /// Get the current authenticated user
  User? getCurrentUser();

  /// Sign out the current user
  Future<void> signOut();
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw AuthException('Failed to sign in as guest: ${e.toString()}');
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please try again in a few minutes.';
      case 'operation-not-allowed':
        return 'Anonymous authentication is not enabled. Please contact support.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}
