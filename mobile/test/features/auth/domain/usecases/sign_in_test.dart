import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/domain/usecases/sign_in.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(authRepository: mockRepository);
  });

  group('SignInUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(
      uid: 'test-uid',
      isAnonymous: false,
      email: testEmail,
      createdAt: DateTime.now(),
    );

    test(
      'should call signInWithEmail on repository with correct params',
      () async {
        // Arrange
        when(
          () => mockRepository.signInWithEmail(testEmail, testPassword),
        ).thenAnswer((_) async => testUser);

        // Act
        final result = await useCase(testEmail, testPassword);

        // Assert
        expect(result, testUser);
        verify(
          () => mockRepository.signInWithEmail(testEmail, testPassword),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should throw exception when repository throws', () async {
      // Arrange
      final exception = Exception('Sign-in failed');
      when(
        () => mockRepository.signInWithEmail(testEmail, testPassword),
      ).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(testEmail, testPassword),
        throwsA(equals(exception)),
      );
      verify(
        () => mockRepository.signInWithEmail(testEmail, testPassword),
      ).called(1);
    });

    test('should throw exception on wrong credentials', () async {
      // Arrange
      final exception = Exception('Invalid email or password');
      when(
        () => mockRepository.signInWithEmail(testEmail, 'wrongpassword'),
      ).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(testEmail, 'wrongpassword'),
        throwsA(equals(exception)),
      );
    });
  });
}
