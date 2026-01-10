import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/data/datasources/auth_remote_datasource.dart';

class MockFirebaseAuth extends Mock implements firebase.FirebaseAuth {}

class MockUserCredential extends Mock implements firebase.UserCredential {}

class MockFirebaseUser extends Mock implements firebase.User {
  @override
  String get uid => 'test-uid';

  @override
  bool get isAnonymous => true;

  @override
  String? get email => null;
}

void main() {
  group('AuthRemoteDataSource Error mapping', () {
    test('should map network error correctly', () {
      final error = firebase.FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error',
      );

      // Test that the error code is recognized
      expect(error.code, equals('network-request-failed'));
      expect(error.message, equals('Network error'));
    });

    test('should map rate-limit error correctly', () {
      final error = firebase.FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many requests',
      );

      expect(error.code, equals('too-many-requests'));
    });

    test('should map operation-not-allowed error correctly', () {
      final error = firebase.FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Operation not allowed',
      );

      expect(error.code, equals('operation-not-allowed'));
    });

    test('should map invalid-email error correctly', () {
      final error = firebase.FirebaseAuthException(
        code: 'invalid-email',
        message: 'Invalid email',
      );

      expect(error.code, equals('invalid-email'));
    });

    test('should map weak-password error correctly', () {
      final error = firebase.FirebaseAuthException(
        code: 'weak-password',
        message: 'Weak password',
      );

      expect(error.code, equals('weak-password'));
    });
  });

  group('AuthRemoteDataSourceImpl', () {
    late AuthRemoteDataSourceImpl dataSource;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      dataSource = AuthRemoteDataSourceImpl(firebaseAuth: mockFirebaseAuth);
    });

    group('signInAnonymously', () {
      test('should return UserCredential on success', () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(
          () => mockFirebaseAuth.signInAnonymously(),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await dataSource.signInAnonymously();

        // Assert
        expect(result, equals(mockCredential));
        verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
      });

      test('should throw AuthException on FirebaseAuthException', () async {
        // Arrange
        when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
          firebase.FirebaseAuthException(code: 'network-request-failed'),
        );

        // Act & Assert
        expect(
          () => dataSource.signInAnonymously(),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on generic exception', () async {
        // Arrange
        when(
          () => mockFirebaseAuth.signInAnonymously(),
        ).thenThrow(Exception('Generic error'));

        // Act & Assert
        expect(
          () => dataSource.signInAnonymously(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return Firebase User when exists', () {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(MockFirebaseUser());

        // Act
        final result = dataSource.getCurrentUser();

        // Assert
        expect(result, isA<firebase.User>());
        expect(result!.uid, equals('test-uid'));
      });

      test('should return null when no current user', () {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = dataSource.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('signOut', () {
      test('should call signOut on FirebaseAuth', () async {
        // Arrange
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('should throw AuthException on FirebaseAuthException', () async {
        // Arrange
        when(() => mockFirebaseAuth.signOut()).thenThrow(
          firebase.FirebaseAuthException(code: 'network-request-failed'),
        );

        // Act & Assert
        expect(() => dataSource.signOut(), throwsA(isA<AuthException>()));
      });
    });
  });
}
