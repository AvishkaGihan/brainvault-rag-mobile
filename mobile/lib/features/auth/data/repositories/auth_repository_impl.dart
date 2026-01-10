import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signInAsGuest() async {
    final userCredential = await remoteDataSource.signInAnonymously();
    return _mapFirebaseUserToEntity(userCredential.user!);
  }

  @override
  User? getCurrentUser() {
    final firebaseUser = remoteDataSource.getCurrentUser();
    return firebaseUser != null ? _mapFirebaseUserToEntity(firebaseUser) : null;
  }

  @override
  Stream<User?> authStateChanges() {
    return firebase.FirebaseAuth.instance.authStateChanges().map((
      firebaseUser,
    ) {
      return firebaseUser != null
          ? _mapFirebaseUserToEntity(firebaseUser)
          : null;
    });
  }

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  /// Map Firebase User to domain User entity
  User _mapFirebaseUserToEntity(firebase.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      email: firebaseUser.email,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }
}
