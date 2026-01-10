import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:brainvault/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:brainvault/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:brainvault/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFirebaseUser extends Mock implements firebase.User {
  @override
  String get uid => 'test-uid';

  @override
  bool get isAnonymous => true;

  @override
  String? get email => null;

  @override
  firebase.UserMetadata get metadata =>
      firebase.UserMetadata(DateTime.now().millisecondsSinceEpoch, null);
}

class MockUserCredential extends Mock implements firebase.UserCredential {
  @override
  firebase.User get user => MockFirebaseUser();
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
          mockDataSource.signInAnonymously(),
        ).thenAnswer((_) async => mockCredential);

        // Act
        final result = await repository.signInAsGuest();

        // Assert
        expect(result, isA<User>());
        expect(result.uid, equals('test-uid'));
        expect(result.isAnonymous, isTrue);
        verify(mockDataSource.signInAnonymously()).called(1);
      });

      test('should throw exception when signInAnonymously fails', () async {
        // Arrange
        when(
          mockDataSource.signInAnonymously(),
        ).thenThrow(Exception('Auth failed'));

        // Act & Assert
        expect(() => repository.signInAsGuest(), throwsException);
        verify(mockDataSource.signInAnonymously()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return User when user exists', () {
        // Arrange
        when(mockDataSource.getCurrentUser()).thenReturn(MockFirebaseUser());

        // Act
        final result = repository.getCurrentUser();

        // Assert
        expect(result, isA<User>());
        expect(result!.uid, equals('test-uid'));
        verify(mockDataSource.getCurrentUser()).called(1);
      });

      test('should return null when no user', () {
        // Arrange
        when(mockDataSource.getCurrentUser()).thenReturn(null);

        // Act
        final result = repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(mockDataSource.getCurrentUser()).called(1);
      });
    });

    group('signOut', () {
      test('should call signOut on data source', () async {
        // Arrange
        when(mockDataSource.signOut()).thenAnswer((_) async {});

        // Act
        await repository.signOut();

        // Assert
        verify(mockDataSource.signOut()).called(1);
      });
    });
  });
}
