import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Register with email and password
  Future<UserCredential> registerWithEmail(String email, String password);

  /// Create user profile in Firestore
  Future<void> createUserProfile(String uid, String email);

  /// Get the current authenticated user
  User? getCurrentUser();

  /// Sign out the current user
  Future<void> signOut();
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

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
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw AuthException('Failed to register: ${e.toString()}');
    }
  }

  @override
  Future<void> createUserProfile(String uid, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email.toLowerCase(),
        'displayName': '',
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {},
      }, SetOptions(merge: false));
    } catch (e) {
      throw AuthException('Failed to create user profile: ${e.toString()}');
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
      case 'email-already-in-use':
        return 'This email is already registered. Please try logging in or use a different email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use letters, numbers, and symbols.';
      case 'operation-not-allowed':
        return 'Email/Password registration is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Connection error. Please check your internet and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}
