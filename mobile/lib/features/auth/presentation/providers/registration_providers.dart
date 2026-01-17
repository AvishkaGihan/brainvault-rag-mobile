import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import 'auth_dependency_providers.dart';

/// State class for user registration form
/// Manages form fields, validation errors, and loading state
class RegistrationFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;

  const RegistrationFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
  });

  RegistrationFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? generalError,
  }) {
    return RegistrationFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      generalError: generalError,
    );
  }

  bool get isEmailValid => isValidEmail(email);

  bool get isPasswordValid => isValidPassword(password);

  bool get isPasswordMatching => isPasswordMatch(password, confirmPassword);

  bool get isFormValid =>
      isEmailValid && isPasswordValid && isPasswordMatching && !isLoading;
}

/// Notifier for managing registration form state
/// Handles form field updates, validation, and form reset
class RegistrationFormNotifier extends Notifier<RegistrationFormState> {
  @override
  RegistrationFormState build() {
    return const RegistrationFormState();
  }

  /// Updates the email field and validates it
  void setEmail(String email) {
    final error = validateEmail(email);
    state = state.copyWith(email: email, emailError: error);
  }

  /// Updates the password field and validates it
  void setPassword(String password) {
    final error = validatePassword(password);
    state = state.copyWith(password: password, passwordError: error);
  }

  /// Updates the confirm password field and validates match
  void setConfirmPassword(String confirmPassword) {
    final error = validatePasswordMatch(state.password, confirmPassword);
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: error,
    );
  }

  /// Resets the form to initial state
  void reset() {
    state = const RegistrationFormState();
  }

  /// Validates email and returns error message if invalid
  String? validateEmail(String email) => getEmailError(email);

  /// Validates password and returns error message if invalid
  String? validatePassword(String password) => getPasswordError(password);

  /// Validates password match and returns error message if not matching
  String? validatePasswordMatch(String password, String confirmPassword) =>
      getPasswordMatchError(password, confirmPassword);
}

/// Provider for RegistrationFormNotifier
/// Exposes the registration form state and actions to the UI
final registrationFormProvider =
    NotifierProvider<RegistrationFormNotifier, RegistrationFormState>(() {
      return RegistrationFormNotifier();
    });

/// State class for user registration process
/// Tracks loading state, errors, and success status during registration
class RegistrationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegistrationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegistrationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for handling user registration
/// Manages the async registration process and state
class RegistrationNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Performs user registration with email and password
  /// Updates state to loading, executes registration, handles success/error
  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.watch(signUpUseCaseProvider);
      await useCase(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  /// Resets the registration state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for RegistrationNotifier
/// Exposes the registration async state and actions to the UI
final registrationProvider = AsyncNotifierProvider<RegistrationNotifier, void>(
  () {
    return RegistrationNotifier();
  },
);
