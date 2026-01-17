import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import 'auth_dependency_providers.dart';

/// State class for forgot password form
/// Manages form fields, validation errors, and loading state
class ForgotPasswordFormState {
  final String email;
  final bool isLoading;
  final String? emailError;
  final String? generalError;

  const ForgotPasswordFormState({
    this.email = '',
    this.isLoading = false,
    this.emailError,
    this.generalError,
  });

  ForgotPasswordFormState copyWith({
    String? email,
    bool? isLoading,
    String? emailError,
    String? generalError,
  }) {
    return ForgotPasswordFormState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      emailError: emailError,
      generalError: generalError,
    );
  }

  bool get isEmailValid => isValidEmail(email);

  bool get isFormValid => isEmailValid && !isLoading;
}

/// Notifier for managing forgot password form state
/// Handles form field updates, validation, and form reset
class ForgotPasswordFormNotifier extends Notifier<ForgotPasswordFormState> {
  @override
  ForgotPasswordFormState build() {
    return const ForgotPasswordFormState();
  }

  /// Updates the email field and validates it
  void setEmail(String email) {
    final error = validateEmail(email);
    state = state.copyWith(email: email, emailError: error);
  }

  /// Sets loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Sets general error message
  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  /// Clears validation errors
  void clearErrors() {
    state = state.copyWith(emailError: null, generalError: null);
  }

  /// Resets the form to initial state
  void reset() {
    state = const ForgotPasswordFormState();
  }

  /// Validates email and returns error message if invalid
  String? validateEmail(String email) => getEmailError(email);
}

/// Provider for ForgotPasswordFormNotifier
/// Exposes the forgot password form state and actions to the UI
final forgotPasswordFormProvider =
    NotifierProvider<ForgotPasswordFormNotifier, ForgotPasswordFormState>(() {
      return ForgotPasswordFormNotifier();
    });

/// Notifier for handling password reset
/// Manages the async password reset process and state
class PasswordResetNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Sends password reset email to the provided email address
  /// Always shows success to prevent email enumeration attacks
  Future<void> sendResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.watch(resetPasswordUseCaseProvider);
      await useCase.call(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(mapPasswordResetErrorToUserMessage(e), st);
    }
  }

  /// Resets the password reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for PasswordResetNotifier
/// Exposes the password reset async state and actions to the UI
final passwordResetProvider =
    AsyncNotifierProvider<PasswordResetNotifier, void>(() {
      return PasswordResetNotifier();
    });
