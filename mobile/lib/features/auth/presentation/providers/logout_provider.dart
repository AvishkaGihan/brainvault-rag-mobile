import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_dependency_providers.dart';

/// State class for logout operation
class LogoutState {
  final bool isLoading;
  final String? error;

  const LogoutState({this.isLoading = false, this.error});

  LogoutState copyWith({bool? isLoading, String? error}) {
    return LogoutState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

/// Notifier for managing logout state
class LogoutNotifier extends Notifier<LogoutState> {
  @override
  LogoutState build() {
    return const LogoutState();
  }

  /// Execute logout and return success status
  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(logoutUseCaseProvider);
      await useCase();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Provider for logout notifier
final logoutProvider = NotifierProvider<LogoutNotifier, LogoutState>(
  LogoutNotifier.new,
);
