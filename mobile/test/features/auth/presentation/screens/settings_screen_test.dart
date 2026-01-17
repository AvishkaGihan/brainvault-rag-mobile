import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/presentation/providers/auth_state_providers.dart';
import 'package:brainvault/features/auth/presentation/screens/settings_screen.dart';
import 'package:brainvault/features/auth/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:brainvault/features/auth/presentation/widgets/guest_logout_warning_dialog.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('should render account section', (tester) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsWidgets);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should display user email for registered users', (
      tester,
    ) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: 'user@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Guest'), findsNothing);
    });

    testWidgets('should display "Guest" for anonymous users', (tester) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: null,
        isAnonymous: true,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Guest'), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
    });

    testWidgets(
      'should show standard confirmation dialog for registered users',
      (tester) async {
        // Arrange
        final mockUser = User(
          uid: 'test-uid',
          email: 'user@example.com',
          isAnonymous: false,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
            ],
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Sign Out button
        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
        expect(find.text('Sign Out?'), findsOneWidget);
        expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      },
    );

    testWidgets('should show guest warning dialog for anonymous users', (
      tester,
    ) async {
      // Arrange
      final mockUser = User(
        uid: 'test-uid',
        email: null,
        isAnonymous: true,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sign Out button
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GuestLogoutWarningDialog), findsOneWidget);
      expect(find.text('Sign Out as Guest?'), findsOneWidget);
      expect(
        find.textContaining('signing out will delete all your data'),
        findsOneWidget,
      );
    });
  });
}
