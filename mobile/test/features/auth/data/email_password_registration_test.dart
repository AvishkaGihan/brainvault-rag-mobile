import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/data/datasources/auth_remote_datasource.dart';

class MockFirebaseAuth extends Mock implements firebase.FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock {}

class MockDocumentReference<T> extends Mock {}

class MockUserCredential extends Mock implements firebase.UserCredential {}

class MockFirebaseUser extends Mock implements firebase.User {
  final String _uid;
  final String _email;

  MockFirebaseUser({String uid = 'test-uid', String email = 'test@example.com'})
    : _uid = uid,
      _email = email;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  bool get isAnonymous => false;

  @override
  firebase.UserMetadata get metadata => _MockUserMetadata();
}

class _MockUserMetadata extends Mock implements firebase.UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
}

void main() {
  group('Email/Password Registration', () {
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

    group('registerWithEmail', () {
      const testEmail = 'test@example.com';
      const testPassword = 'Password123';

      test('should create user account with email and password', () async {
        // Arrange
        final mockUser = MockFirebaseUser(email: testEmail);
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);

        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await dataSource.registerWithEmail(
          testEmail,
          testPassword,
        );

        // Assert
        expect(result, equals(mockCredential));
        verify(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).called(1);
      });

      test(
        'should throw AuthException on email-already-in-use error',
        () async {
          // Arrange
          final exception = firebase.FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          );

          when(
            () => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => dataSource.registerWithEmail(testEmail, testPassword),
            throwsA(isA<AuthException>()),
          );
        },
      );

      test('should throw AuthException on invalid-email error', () async {
        // Arrange
        final exception = firebase.FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email',
        );

        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'invalid-email',
            password: testPassword,
          ),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => dataSource.registerWithEmail('invalid-email', testPassword),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw AuthException on weak-password error', () async {
        // Arrange
        final exception = firebase.FirebaseAuthException(
          code: 'weak-password',
          message: 'Weak password',
        );

        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'weak',
          ),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => dataSource.registerWithEmail(testEmail, 'weak'),
          throwsA(isA<AuthException>()),
        );
      });

      test(
        'should throw AuthException on network-request-failed error',
        () async {
          // Arrange
          final exception = firebase.FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Network error',
          );

          when(
            () => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => dataSource.registerWithEmail(testEmail, testPassword),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('createUserProfile', () {
      const testUid = 'test-uid';
      const testEmail = 'test@example.com';

      test('should create user profile in Firestore', () async {
        // Arrange
        final mockCollection =
            MockCollectionReference<Map<String, dynamic>>()
                as CollectionReference<Map<String, dynamic>>;
        final mockDoc =
            MockDocumentReference<Map<String, dynamic>>()
                as DocumentReference<Map<String, dynamic>>;

        when(
          () => mockFirestore.collection('users'),
        ).thenReturn(mockCollection);
        when(() => mockCollection.doc(testUid)).thenReturn(mockDoc);
        when(() => mockDoc.set(any(), any())).thenAnswer((_) async {
          return;
        });

        // Act
        await dataSource.createUserProfile(testUid, testEmail);

        // Assert
        verify(() => mockFirestore.collection('users')).called(1);
        verify(() => mockCollection.doc(testUid)).called(1);
        verify(() => mockDoc.set(any(), any())).called(1);
      });
    });
  });
}
