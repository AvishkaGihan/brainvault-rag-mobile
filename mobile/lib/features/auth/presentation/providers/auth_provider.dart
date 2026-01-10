import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_up.dart';
import '../../../../core/utils/validators.dart';

/// Provides the remote data source for Firebase authentication

/// Provides the remote data source for Firebase authentication
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Provides the auth repository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provides the sign-in as guest use case
final signInAsGuestUseCaseProvider = Provider<SignInAsGuestUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInAsGuestUseCase(authRepository: repository);
});

/// Provides the sign-up use case
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(authRepository: repository);
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Provides a stream of authentication state changes
/// Returns null when user is signed out, User object when signed in
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Provides the current authenticated user (one-time snapshot)
final currentUserProvider = Provider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

// Simple state class for guest sign-in
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

// Notifier for guest sign-in - simple implementation
class GuestSignInNotifier extends Notifier<GuestSignInState> {
  @override
  GuestSignInState build() {
    return const GuestSignInState();
  }

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

  void reset() {
    state = const GuestSignInState();
  }
}

/// Provides the guest sign-in notifier
final guestSignInProvider =
    NotifierProvider<GuestSignInNotifier, GuestSignInState>(() {
      return GuestSignInNotifier();
    });

// ============================================================================
// REGISTRATION STATE & PROVIDERS
// ============================================================================

/// State for registration form validation
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

  /// Check if email is valid (basic regex check)
  bool get isEmailValid {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Check if password is valid (>= 6 characters)
  bool get isPasswordValid => password.length >= 6;

  /// Check if passwords match
  bool get isPasswordMatching =>
      password.isNotEmpty && password == confirmPassword;

  /// Check if entire form is valid
  bool get isFormValid =>
      isEmailValid && isPasswordValid && isPasswordMatching && !isLoading;
}

/// Notifier for registration form state
class RegistrationFormNotifier extends Notifier<RegistrationFormState> {
  @override
  RegistrationFormState build() {
    return const RegistrationFormState();
  }

  void setEmail(String email) {
    final error = validateEmail(email);
    state = state.copyWith(email: email, emailError: error);
  }

  void setPassword(String password) {
    final error = validatePassword(password);
    state = state.copyWith(password: password, passwordError: error);
  }

  void setConfirmPassword(String confirmPassword) {
    final error = validatePasswordMatch(state.password, confirmPassword);
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: error,
    );
  }

  void reset() {
    state = const RegistrationFormState();
  }

  String? validateEmail(String email) => getEmailError(email);

  String? validatePassword(String password) => getPasswordError(password);

  String? validatePasswordMatch(String password, String confirmPassword) =>
      getPasswordMatchError(password, confirmPassword);
}

/// Provides the registration form state notifier
final registrationFormProvider =
    NotifierProvider<RegistrationFormNotifier, RegistrationFormState>(() {
      return RegistrationFormNotifier();
    });

/// State for registration async operation
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

/// Notifier for registration async operation
class RegistrationNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

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

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provides the registration async notifier
final registrationProvider = AsyncNotifierProvider<RegistrationNotifier, void>(
  () {
    return RegistrationNotifier();
  },
);

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// Provides a boolean indicating if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provides a boolean indicating if user is loading authentication state
final isAuthLoadingProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider);
  return user.isLoading;
});

/// Provides error message from sign-in operation (if any)
final authErrorProvider = Provider<String?>((ref) {
  final signInState = ref.watch(guestSignInProvider);
  return signInState.error;
});

/// Provides loading state from sign-in operation
final isSigningInProvider = Provider<bool>((ref) {
  final signInState = ref.watch(guestSignInProvider);
  return signInState.isLoading;
});

/// Maps exceptions to user-friendly error messages
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
