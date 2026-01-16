import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/domain/usecases/reset_password.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ResetPasswordUseCase resetPasswordUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    resetPasswordUseCase = ResetPasswordUseCase(
      authRepository: mockAuthRepository,
    );
  });

  group('ResetPasswordUseCase', () {
    const testEmail = 'test@example.com';

    test(
      'should call repository.sendPasswordResetEmail with correct email',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.sendPasswordResetEmail(testEmail),
        ).thenAnswer((_) async {});

        // Act
        await resetPasswordUseCase(testEmail);

        // Assert
        verify(
          () => mockAuthRepository.sendPasswordResetEmail(testEmail),
        ).called(1);
      },
    );

    test('should throw exception when repository throws', () async {
      // Arrange
      final exception = Exception('Network error');
      when(
        () => mockAuthRepository.sendPasswordResetEmail(testEmail),
      ).thenThrow(exception);

      // Act & Assert
      expect(() => resetPasswordUseCase(testEmail), throwsA(isA<Exception>()));
    });

    test('should handle empty email string', () async {
      // Arrange
      const emptyEmail = '';
      when(
        () => mockAuthRepository.sendPasswordResetEmail(emptyEmail),
      ).thenAnswer((_) async {});

      // Act
      await resetPasswordUseCase(emptyEmail);

      // Assert
      verify(
        () => mockAuthRepository.sendPasswordResetEmail(emptyEmail),
      ).called(1);
    });
  });
}
