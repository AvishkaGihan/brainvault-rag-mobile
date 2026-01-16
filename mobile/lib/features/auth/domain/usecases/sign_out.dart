import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainvault/core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out the current user
///
/// This use case handles the complete logout flow:
/// 1. Clears local caches (document list, etc.)
/// 2. Signs out from Firebase Auth
/// 3. Riverpod providers auto-invalidate when auth state changes
///
/// Note: GoRouter's redirect logic automatically navigates to /login
/// when authStateChanges() emits null.
class SignOutUseCase {
  final AuthRepository authRepository;

  SignOutUseCase({required this.authRepository});

  /// Execute the logout operation
  ///
  /// Clears local caches and signs out from Firebase.
  /// Throws Exception if sign-out fails.
  Future<void> call() async {
    // 1. Clear local caches
    final prefs = await SharedPreferences.getInstance();
    await _clearLocalCaches(prefs);

    // 2. Sign out from Firebase
    await authRepository.signOut();

    // 3. Riverpod providers automatically invalidate when
    // authStateChanges() emits null
  }

  Future<void> _clearLocalCaches(SharedPreferences prefs) async {
    final cacheKeys = [
      AppConstants.cachedDocumentsKey,
      AppConstants.cachedChatHistoryKey,
      AppConstants.userAuthTokenKey,
      AppConstants.userEmailKey,
    ];

    for (final key in cacheKeys) {
      await prefs.remove(key);
    }
  }
}
