import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_dependency_providers.dart';

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
      state = state.copyWith(isLoading: false, error: e.toString());
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
