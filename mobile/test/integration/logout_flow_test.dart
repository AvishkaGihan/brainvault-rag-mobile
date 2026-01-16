import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/presentation/providers/auth_provider.dart';
import 'package:brainvault/features/settings/presentation/screens/settings_screen.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';
import 'package:brainvault/features/settings/presentation/providers/logout_provider.dart';

void main() {
  group('Logout Flow Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Full logout flow for registered user', (tester) async {
      // Arrange - Mock authenticated user
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      var isLoggedOut = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(isLoggedOut ? null : mockUser),
            ),
            logoutProvider.overrideWith(
              () => TestLogoutNotifier(() {
                isLoggedOut = true;
              }),
            ),
          ],
          child: MaterialApp(
            home: const SettingsScreen(),
            routes: {'/login': (context) => const LoginScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Sign Out?'), findsOneWidget);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);

      // Tap Sign Out in dialog
      final signOutButtons = find.text('Sign Out');
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      // Assert - User should be logged out (in real app, would redirect)
      expect(isLoggedOut, isTrue);
    });

    testWidgets('Full logout flow for guest user - Sign Out Anyway', (
      tester,
    ) async {
      // Arrange - Mock guest user
      final mockUser = User(
        uid: 'test-uid',
        email: null,
        isAnonymous: true,
        createdAt: DateTime.now(),
      );

      var isLoggedOut = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(isLoggedOut ? null : mockUser),
            ),
            logoutProvider.overrideWith(
              () => TestLogoutNotifier(() {
                isLoggedOut = true;
              }),
            ),
          ],
          child: MaterialApp(
            home: const SettingsScreen(),
            routes: {'/login': (context) => const LoginScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Should show guest warning dialog
      expect(find.text('Sign Out as Guest?'), findsOneWidget);
      expect(
        find.textContaining('signing out will delete all your data'),
        findsOneWidget,
      );

      // Tap Sign Out Anyway
      await tester.tap(find.text('Sign Out Anyway'));
      await tester.pumpAndSettle();

      // Assert - User should be logged out
      expect(isLoggedOut, isTrue);
    });

    testWidgets('Guest user choosing Create Account navigates to register', (
      tester,
    ) async {
      // Arrange - Mock guest user
      final mockUser = User(
        uid: 'test-uid',
        email: null,
        isAnonymous: true,
        createdAt: DateTime.now(),
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) =>
                const Scaffold(body: Text('Register Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Tap Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to register
      expect(find.text('Register Screen'), findsOneWidget);
    });

    testWidgets('Cancel button closes dialog without logging out', (
      tester,
    ) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      var isLoggedOut = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(isLoggedOut ? null : mockUser),
            ),
            logoutProvider.overrideWith(
              () => TestLogoutNotifier(() {
                isLoggedOut = true;
              }),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - Dialog closed, user still logged in
      expect(find.text('Sign Out?'), findsNothing);
      expect(isLoggedOut, isFalse);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Error during logout shows snackbar', (tester) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
            logoutProvider.overrideWith(() => TestLogoutNotifierWithError()),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Tap Sign Out in dialog
      final signOutButtons = find.text('Sign Out');
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      // Assert - Should show error snackbar
      expect(find.text("Couldn't sign out. Please try again."), findsOneWidget);
    });
  });
}

/// Test notifier for simulating successful logout
class TestLogoutNotifier extends LogoutNotifier {
  final VoidCallback onLogout;

  TestLogoutNotifier(this.onLogout);

  @override
  Future<bool> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 50));
    onLogout();
    state = state.copyWith(isLoading: false);
    return true;
  }
}

/// Test notifier for simulating logout failure
class TestLogoutNotifierWithError extends LogoutNotifier {
  @override
  Future<bool> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 50));
    state = state.copyWith(isLoading: false, error: 'Logout failed');
    return false;
  }
}
