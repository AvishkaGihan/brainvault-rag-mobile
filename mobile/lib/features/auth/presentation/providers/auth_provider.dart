import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_as_guest.dart';

// ============================================================================
// DEPENDENCY INJECTION PROVIDERS
// ============================================================================

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
