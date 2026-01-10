import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/domain/usecases/sign_up.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(authRepository: mockRepository);
  });

  group('SignUpUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(
      uid: 'test-uid',
      isAnonymous: false,
      email: testEmail,
      createdAt: DateTime.now(),
    );

    test(
      'should call registerWithEmail on repository with correct params',
      () async {
        // Arrange
        when(
          () => mockRepository.registerWithEmail(testEmail, testPassword),
        ).thenAnswer((_) async => testUser);

        // Act
        final result = await useCase(testEmail, testPassword);

        // Assert
        expect(result, testUser);
        verify(
          () => mockRepository.registerWithEmail(testEmail, testPassword),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should throw exception when repository throws', () async {
      // Arrange
      final exception = Exception('Registration failed');
      when(
        () => mockRepository.registerWithEmail(testEmail, testPassword),
      ).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(testEmail, testPassword),
        throwsA(equals(exception)),
      );
      verify(
        () => mockRepository.registerWithEmail(testEmail, testPassword),
      ).called(1);
    });
  });
}
