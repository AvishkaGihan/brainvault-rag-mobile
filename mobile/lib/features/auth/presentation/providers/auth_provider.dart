import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/reset_password.dart';
import '../../../../core/utils/validators.dart';

/// Authentication providers and state management for the BrainVault app
/// This file contains Riverpod providers for dependency injection and state notifiers
/// for handling guest sign-in and user registration flows.

/// Provider for AuthRemoteDataSource implementation
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Provider for AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for SignInAsGuestUseCase
final signInAsGuestUseCaseProvider = Provider<SignInAsGuestUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInAsGuestUseCase(authRepository: repository);
});

/// Provider for SignUpUseCase
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(authRepository: repository);
});

/// Provider for SignInUseCase
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(authRepository: repository);
});

/// Provider for ResetPasswordUseCase
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(authRepository: repository);
});

/// Stream provider for authentication state changes
///
/// Emits the current user whenever auth state changes:
/// - User signs in (email/password or guest) → emits User
/// - User signs out → emits null
/// - Token is refreshed (hourly, automatic) → emits User
/// - Firebase session is restored on app launch → emits User or null
///
/// If token refresh fails or session expires, Firebase automatically
/// logs out the user (emits null), triggering redirect to login screen.
/// No manual error handling needed - GoRouter's redirect logic will
/// automatically route to /login when user is null.
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Provider for the current authenticated user
final currentUserProvider = Provider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// State class for guest sign-in process
/// Tracks loading state and any errors during guest authentication
class GuestSignInState {
  final bool isLoading;
  final String? error;

  const GuestSignInState({this.isLoading = false, this.error});

  GuestSignInState copyWith({bool? isLoading, String? error}) {
    return GuestSignInState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing guest sign-in state
/// Handles the business logic for signing in as a guest user
class GuestSignInNotifier extends Notifier<GuestSignInState> {
  @override
  GuestSignInState build() {
    return const GuestSignInState();
  }

  /// Initiates guest sign-in process
  /// Updates state to loading, performs sign-in, and handles success/error
  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.watch(signInAsGuestUseCaseProvider);
      await useCase();
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapErrorToUserMessage(e),
      );
    }
  }

  /// Resets the sign-in state to initial values
  void reset() {
    state = const GuestSignInState();
  }
}

/// Provider for GuestSignInNotifier
/// Exposes the guest sign-in state and actions to the UI
final guestSignInProvider =
    NotifierProvider<GuestSignInNotifier, GuestSignInState>(() {
      return GuestSignInNotifier();
    });

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
      state = AsyncValue.error(_mapErrorToUserMessage(e), st);
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
      state = AsyncValue.error(_mapErrorToUserMessage(e), st);
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
      state = AsyncValue.error(_mapPasswordResetErrorToUserMessage(e), st);
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

/// Provider that determines if a user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider that checks if authentication is currently loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user.isLoading;
});

/// Provider for authentication error messages
final authErrorProvider = Provider<String?>((ref) {
  final signInState = ref.watch(guestSignInProvider);
  return signInState.error;
});

/// Provider that checks if guest sign-in is in progress
final isSigningInProvider = Provider<bool>((ref) {
  final signInState = ref.watch(guestSignInProvider);
  return signInState.isLoading;
});

/// Maps authentication errors to user-friendly messages
/// Handles common Firebase auth errors and provides readable feedback
String _mapErrorToUserMessage(Object error) {
  if (error is Exception) {
    final message = error.toString();
    if (message.contains('Network error')) {
      return 'Network error. Please check your connection and try again.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many sign-in attempts. Please try again in a few minutes.';
    } else if (message.contains('operation-not-allowed')) {
      return 'Guest authentication is not available. Please contact support.';
    }
  }
  return 'Sign-in failed. Please try again.';
}

/// Maps password reset errors to user-friendly messages
/// Context-specific error handling for password reset flow per AC7
String _mapPasswordResetErrorToUserMessage(Object error) {
  if (error is Exception) {
    final message = error.toString();
    if (message.contains('network-request-failed') ||
        message.contains('Network error')) {
      return 'Couldn\'t send reset link. Please check your internet connection.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many requests. Please try again in a few minutes.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
  }
  return 'Something went wrong. Please try again.';
}
