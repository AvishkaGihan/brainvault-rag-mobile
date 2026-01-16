import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainvault/core/constants/app_constants.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/domain/usecases/sign_out.dart';

// Mock class for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUseCase signOutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signOutUseCase = SignOutUseCase(authRepository: mockAuthRepository);
  });

  setUpAll(() {
    registerFallbackValue(MockAuthRepository());
  });

  group('SignOutUseCase', () {
    test('should clear SharedPreferences cache when logging out', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        AppConstants.cachedDocumentsKey: 'test_data',
        AppConstants.cachedChatHistoryKey: 'chat_data',
      });
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act
      await signOutUseCase();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.cachedDocumentsKey), isNull);
      expect(prefs.getString(AppConstants.cachedChatHistoryKey), isNull);
    });

    test('should call authRepository.signOut()', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act
      await signOutUseCase();

      // Assert
      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('should propagate errors from authRepository.signOut()', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final exception = Exception('Sign out failed');
      when(() => mockAuthRepository.signOut()).thenThrow(exception);

      // Act & Assert
      await expectLater(signOutUseCase(), throwsA(equals(exception)));
    });

    test('should clear cache before signing out', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        AppConstants.cachedDocumentsKey: 'test_data',
        AppConstants.cachedChatHistoryKey: 'chat_data',
      });
      final callOrder = <String>[];

      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {
        callOrder.add('signOut');
      });

      // Act
      await signOutUseCase();

      // Assert - verify cache is cleared before signOut
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.cachedDocumentsKey), isNull);
      expect(prefs.getString(AppConstants.cachedChatHistoryKey), isNull);
      expect(callOrder, contains('signOut'));
    });
  });
}
