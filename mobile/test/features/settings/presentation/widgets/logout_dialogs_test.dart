import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:brainvault/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:brainvault/features/settings/presentation/widgets/guest_logout_warning_dialog.dart';
import 'package:brainvault/features/settings/presentation/providers/logout_provider.dart';

void main() {
  group('LogoutConfirmationDialog', () {
    testWidgets('should show Cancel and Sign Out buttons', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const LogoutConfirmationDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Out?'), findsOneWidget);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget); // Button
    });

    testWidgets('should close dialog when Cancel is tapped', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const LogoutConfirmationDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog should be closed
      expect(find.byType(LogoutConfirmationDialog), findsNothing);
    });

    testWidgets('should show loading indicator during logout', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [logoutProvider.overrideWith(() => TestLogoutNotifier())],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const LogoutConfirmationDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Sign Out button to trigger logout
      await tester.tap(find.text('Sign Out'));
      await tester.pump();

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('GuestLogoutWarningDialog', () {
    testWidgets('should show warning icon and message', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const GuestLogoutWarningDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Out as Guest?'), findsOneWidget);
      expect(
        find.textContaining('signing out will delete all your data'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show three action buttons', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const GuestLogoutWarningDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign Out Anyway'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const GuestLogoutWarningDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog should be closed
      expect(find.byType(GuestLogoutWarningDialog), findsNothing);
    });

    testWidgets('should navigate to register when Create Account is tapped', (
      tester,
    ) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const GuestLogoutWarningDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) =>
                const Scaffold(body: Text('Register Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act - Tap Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Assert - should navigate to register
      expect(find.text('Register Screen'), findsOneWidget);
    });
  });
}

/// Test notifier for simulating logout states
class TestLogoutNotifier extends LogoutNotifier {
  @override
  LogoutState build() => const LogoutState();

  @override
  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    return true;
  }
}
