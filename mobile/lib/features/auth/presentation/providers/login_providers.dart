import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import 'auth_dependency_providers.dart';
import 'auth_state_providers.dart';

/// State class for user login form
/// Manages form fields, validation errors, and loading state
class LoginFormState {
  final String email;
  final String password;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      emailError: emailError,
      passwordError: passwordError,
      generalError: generalError,
    );
  }

  bool get isEmailValid => isValidEmail(email);

  bool get isPasswordValid => password.isNotEmpty;

  bool get isFormValid => isEmailValid && isPasswordValid && !isLoading;
}

/// Notifier for managing login form state
/// Handles form field updates, validation, and form reset
class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  /// Updates the email field and validates it
  void setEmail(String email) {
    final error = validateEmail(email);
    state = state.copyWith(email: email, emailError: error);
  }

  /// Updates the password field
  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  /// Clears validation errors
  void clearErrors() {
    state = state.copyWith(
      emailError: null,
      passwordError: null,
      generalError: null,
    );
  }

  /// Resets the form to initial state
  void reset() {
    state = const LoginFormState();
  }

  /// Validates email and returns error message if invalid
  String? validateEmail(String email) => getEmailError(email);
}

/// Provider for LoginFormNotifier
/// Exposes the login form state and actions to the UI
final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginFormState>(
  () {
    return LoginFormNotifier();
  },
);

/// Notifier for handling user login
/// Manages the async login process and state
class LoginNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Performs user login with email and password
  /// Updates state to loading, executes login, handles success/error
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.watch(signInUseCaseProvider);
      await useCase(email, password);
      state = const AsyncValue.data(null);
      // Invalidate auth state to trigger navigation
      ref.invalidate(authStateProvider);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  /// Resets the login state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for LoginNotifier
/// Exposes the login async state and actions to the UI
final loginProvider = AsyncNotifierProvider<LoginNotifier, void>(() {
  return LoginNotifier();
});
