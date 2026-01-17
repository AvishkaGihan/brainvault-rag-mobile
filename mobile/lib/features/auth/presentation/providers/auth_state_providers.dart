import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import 'auth_dependency_providers.dart';

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
