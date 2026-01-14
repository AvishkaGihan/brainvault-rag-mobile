import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:brainvault/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:brainvault/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFirebaseUser extends Mock implements firebase.User {
  final String _uid;
  final bool _isAnonymous;
  final String? _email;

  MockFirebaseUser({
    String uid = 'test-uid',
    bool isAnonymous = true,
    String? email,
  }) : _uid = uid,
       _isAnonymous = isAnonymous,
       _email = email;

  @override
  String get uid => _uid;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  String? get email => _email;

  @override
  firebase.UserMetadata get metadata =>
      firebase.UserMetadata(DateTime.now().millisecondsSinceEpoch, null);
}

class MockUserCredential extends Mock implements firebase.UserCredential {
  final firebase.User _user;

  MockUserCredential({firebase.User? user})
    : _user = user ?? MockFirebaseUser();

  @override
  firebase.User get user => _user;
}

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
    });

    group('signInAsGuest', () {
      test('should return User when signInAnonymously succeeds', () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(
          () => mockDataSource.signInAnonymously(),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await repository.signInAsGuest();

        // Assert
        expect(result, isA<User>());
        expect(result.uid, equals('test-uid'));
        expect(result.isAnonymous, isTrue);
        verify(() => mockDataSource.signInAnonymously()).called(1);
      });

      test('should throw exception when signInAnonymously fails', () async {
        // Arrange
        when(
          () => mockDataSource.signInAnonymously(),
        ).thenThrow(Exception('Auth failed'));

        // Act & Assert
        expect(() => repository.signInAsGuest(), throwsException);
        verify(() => mockDataSource.signInAnonymously()).called(1);
      });
    });

    group('signInWithEmail', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should return User when signInWithEmail succeeds', () async {
        // Arrange
        final mockFirebaseUser = MockFirebaseUser(
          uid: 'user-123',
          isAnonymous: false,
          email: testEmail,
        );
        final mockCredential = MockUserCredential(user: mockFirebaseUser);
        when(
          () => mockDataSource.signInWithEmail(testEmail, testPassword),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await repository.signInWithEmail(
          testEmail,
          testPassword,
        );

        // Assert
        expect(result, isA<User>());
        expect(result.uid, equals('user-123'));
        expect(result.isAnonymous, isFalse);
        expect(result.email, equals(testEmail));
        verify(
          () => mockDataSource.signInWithEmail(testEmail, testPassword),
        ).called(1);
      });

      test('should throw AuthException when credentials are invalid', () async {
        // Arrange
        when(
          () => mockDataSource.signInWithEmail(testEmail, testPassword),
        ).thenThrow(AuthException('Invalid email or password'));

        // Act & Assert
        expect(
          () => repository.signInWithEmail(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
        verify(
          () => mockDataSource.signInWithEmail(testEmail, testPassword),
        ).called(1);
      });

      test('should throw exception on network error', () async {
        // Arrange
        when(
          () => mockDataSource.signInWithEmail(testEmail, testPassword),
        ).thenThrow(
          AuthException(
            'Connection error. Please check your internet and try again.',
          ),
        );

        // Act & Assert
        expect(
          () => repository.signInWithEmail(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return User when user exists', () {
        // Arrange
        when(
          () => mockDataSource.getCurrentUser(),
        ).thenReturn(MockFirebaseUser());

        // Act
        final result = repository.getCurrentUser();

        // Assert
        expect(result, isA<User>());
        expect(result!.uid, equals('test-uid'));
        verify(() => mockDataSource.getCurrentUser()).called(1);
      });

      test('should return null when no user', () {
        // Arrange
        when(() => mockDataSource.getCurrentUser()).thenReturn(null);

        // Act
        final result = repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(() => mockDataSource.getCurrentUser()).called(1);
      });
    });

    group('signOut', () {
      test('should call signOut on data source', () async {
        // Arrange
        when(() => mockDataSource.signOut()).thenAnswer((_) async {});

        // Act
        await repository.signOut();

        // Assert
        verify(() => mockDataSource.signOut()).called(1);
      });
    });
  });
}
