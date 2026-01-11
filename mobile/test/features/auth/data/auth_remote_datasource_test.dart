import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
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

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('AuthRemoteDataSourceImpl', () {
    late AuthRemoteDataSourceImpl dataSource;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      dataSource = AuthRemoteDataSourceImpl(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
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

  group('AuthRemoteDataSource Error Mapping', () {
    late AuthRemoteDataSourceImpl dataSource;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      dataSource = AuthRemoteDataSourceImpl(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    test('should map email-already-in-use error correctly', () async {
      when(
        () => mockFirebaseAuth.signInAnonymously(),
      ).thenThrow(firebase.FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'This email is already registered. Please try logging in or use a different email.',
          ),
        ),
      );
    });

    test('should map invalid-email error correctly', () async {
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(firebase.FirebaseAuthException(code: 'invalid-email'));

      expect(
        () => dataSource.registerWithEmail('test@example.com', 'password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Please enter a valid email address.',
          ),
        ),
      );
    });

    test('should map weak-password error correctly', () async {
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(firebase.FirebaseAuthException(code: 'weak-password'));

      expect(
        () => dataSource.registerWithEmail('test@example.com', 'password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Password is too weak. Use letters, numbers, and symbols.',
          ),
        ),
      );
    });

    test('should map operation-not-allowed error correctly', () async {
      when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
        firebase.FirebaseAuthException(code: 'operation-not-allowed'),
      );

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Email/Password registration is not enabled. Please contact support.',
          ),
        ),
      );
    });

    test('should map network-request-failed error correctly', () async {
      when(() => mockFirebaseAuth.signInAnonymously()).thenThrow(
        firebase.FirebaseAuthException(code: 'network-request-failed'),
      );

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Connection error. Please check your internet and try again.',
          ),
        ),
      );
    });

    test('should map too-many-requests error correctly', () async {
      when(
        () => mockFirebaseAuth.signInAnonymously(),
      ).thenThrow(firebase.FirebaseAuthException(code: 'too-many-requests'));

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Too many attempts. Please try again in a few minutes.',
          ),
        ),
      );
    });

    test('should map unknown error to default message', () async {
      when(
        () => mockFirebaseAuth.signInAnonymously(),
      ).thenThrow(firebase.FirebaseAuthException(code: 'unknown-error'));

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Sign-in failed. Please try again.',
          ),
        ),
      );
    });
  });
}
