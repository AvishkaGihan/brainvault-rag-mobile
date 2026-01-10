import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/domain/usecases/sign_in_as_guest.dart';

@GenerateMocks([AuthRepository])
import 'sign_in_as_guest_test.mocks.dart';

void main() {
  group('SignInAsGuestUseCase', () {
    late SignInAsGuestUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = SignInAsGuestUseCase(authRepository: mockRepository);
    });

    test('should return User when repository succeeds', () async {
      // Arrange
      final testUser = User(
        uid: 'test-uid',
        isAnonymous: true,
        email: null,
        createdAt: DateTime.now(),
      );
      when(mockRepository.signInAsGuest()).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(testUser));
      verify(mockRepository.signInAsGuest()).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(mockRepository.signInAsGuest()).thenThrow(Exception('Auth failed'));

      // Act & Assert
      expect(() => useCase(), throwsException);
      verify(mockRepository.signInAsGuest()).called(1);
    });
  });
}
