import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brainvault/features/auth/presentation/providers/registration_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('RegistrationFormNotifier', () {
    test('initial state should be empty and not loading', () {
      final state = container.read(registrationFormProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.emailError, null);
      expect(state.passwordError, null);
      expect(state.confirmPasswordError, null);
      expect(state.generalError, null);
    });

    test('setEmail should update email and clear error', () {
      container
          .read(registrationFormProvider.notifier)
          .setEmail('test@example.com');
      final state = container.read(registrationFormProvider);
      expect(state.email, 'test@example.com');
      expect(state.emailError, null);
    });

    test('setPassword should update password and clear error', () {
      container
          .read(registrationFormProvider.notifier)
          .setPassword('password123');
      final state = container.read(registrationFormProvider);
      expect(state.password, 'password123');
      expect(state.passwordError, null);
    });

    test(
      'setConfirmPassword should update confirmPassword and clear error',
      () {
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('password123');
        final state = container.read(registrationFormProvider);
        expect(state.confirmPassword, 'password123');
        expect(state.confirmPasswordError, null);
      },
    );

    test('reset should clear all fields and errors', () {
      container
          .read(registrationFormProvider.notifier)
          .setEmail('test@example.com');
      container
          .read(registrationFormProvider.notifier)
          .setPassword('password123');
      container
          .read(registrationFormProvider.notifier)
          .setConfirmPassword('password123');
      container.read(registrationFormProvider.notifier).reset();

      final state = container.read(registrationFormProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.emailError, null);
      expect(state.passwordError, null);
      expect(state.confirmPasswordError, null);
    });

    group('Validation', () {
      test('isEmailValid should return false for empty email', () {
        final state = container.read(registrationFormProvider);
        expect(state.isEmailValid, false);
      });

      test('isEmailValid should return false for invalid email', () {
        container
            .read(registrationFormProvider.notifier)
            .setEmail('invalid-email');
        final state = container.read(registrationFormProvider);
        expect(state.isEmailValid, false);
      });

      test('isEmailValid should return true for valid email', () {
        container
            .read(registrationFormProvider.notifier)
            .setEmail('test@example.com');
        final state = container.read(registrationFormProvider);
        expect(state.isEmailValid, true);
      });

      test('isPasswordValid should return false for short password', () {
        container.read(registrationFormProvider.notifier).setPassword('12345');
        final state = container.read(registrationFormProvider);
        expect(state.isPasswordValid, false);
      });

      test('isPasswordValid should return true for valid password', () {
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        final state = container.read(registrationFormProvider);
        expect(state.isPasswordValid, true);
      });

      test(
        'isPasswordMatching should return false when passwords do not match',
        () {
          container
              .read(registrationFormProvider.notifier)
              .setPassword('password123');
          container
              .read(registrationFormProvider.notifier)
              .setConfirmPassword('different');
          final state = container.read(registrationFormProvider);
          expect(state.isPasswordMatching, false);
        },
      );

      test('isPasswordMatching should return true when passwords match', () {
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('password123');
        final state = container.read(registrationFormProvider);
        expect(state.isPasswordMatching, true);
      });

      test('isFormValid should return false when email is invalid', () {
        container.read(registrationFormProvider.notifier).setEmail('invalid');
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('password123');
        final state = container.read(registrationFormProvider);
        expect(state.isFormValid, false);
      });

      test('isFormValid should return false when password is invalid', () {
        container
            .read(registrationFormProvider.notifier)
            .setEmail('test@example.com');
        container.read(registrationFormProvider.notifier).setPassword('123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('123');
        final state = container.read(registrationFormProvider);
        expect(state.isFormValid, false);
      });

      test('isFormValid should return false when passwords do not match', () {
        container
            .read(registrationFormProvider.notifier)
            .setEmail('test@example.com');
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('different');
        final state = container.read(registrationFormProvider);
        expect(state.isFormValid, false);
      });

      test('isFormValid should return true when all fields are valid', () {
        container
            .read(registrationFormProvider.notifier)
            .setEmail('test@example.com');
        container
            .read(registrationFormProvider.notifier)
            .setPassword('password123');
        container
            .read(registrationFormProvider.notifier)
            .setConfirmPassword('password123');
        final state = container.read(registrationFormProvider);
        expect(state.isFormValid, true);
      });

      test('validateEmail should return error for empty email', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validateEmail('');
        expect(result, 'Email is required');
      });

      test('validateEmail should return error for invalid email', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validateEmail('invalid');
        expect(result, 'Please enter a valid email address');
      });

      test('validateEmail should return null for valid email', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validateEmail('test@example.com');
        expect(result, null);
      });

      test('validatePassword should return error for short password', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validatePassword('123');
        expect(result, 'Password must be at least 6 characters');
      });

      test('validatePassword should return null for valid password', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validatePassword('password123');
        expect(result, null);
      });

      test(
        'validatePasswordMatch should return error when passwords do not match',
        () {
          final result = container
              .read(registrationFormProvider.notifier)
              .validatePasswordMatch('password123', 'different');
          expect(result, 'Passwords do not match');
        },
      );

      test('validatePasswordMatch should return null when passwords match', () {
        final result = container
            .read(registrationFormProvider.notifier)
            .validatePasswordMatch('password123', 'password123');
        expect(result, null);
      });
    });
  });
}
