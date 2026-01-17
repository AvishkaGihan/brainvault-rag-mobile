import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/app/app.dart';
import 'package:brainvault/features/auth/domain/entities/user.dart';
import 'package:brainvault/features/auth/domain/repositories/auth_repository.dart';
import 'package:brainvault/features/auth/presentation/providers/auth_provider.dart';
import 'package:brainvault/features/auth/presentation/screens/splash_screen.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';
import 'package:brainvault/features/documents/presentation/screens/documents_screen.dart';

// Mock Repository
class MockAuthRepository implements AuthRepository {
  final Stream<User?> _authStream;

  MockAuthRepository(this._authStream);

  @override
  Stream<User?> authStateChanges() => _authStream;

  @override
  Future<User> signInAsGuest() async {
    throw UnimplementedError();
  }

  @override
  Future<User> registerWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  User? getCurrentUser() => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw UnimplementedError();
  }
}

void main() {
  group('Auth Flow Integration Tests', () {
    testWidgets(
      'app launches, shows splash, navigates to login when not authenticated',
      (WidgetTester tester) async {
        // Arrange - Mock no authenticated user
        final authId = StreamController<User?>.broadcast();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWith(
                (ref) => MockAuthRepository(authId.stream),
              ),
            ],
            child: const BrainVaultApp(),
          ),
        );

        // Act - emit null (not authenticated)
        authId.add(null);

        // Act - Wait for initial frame
        await tester.pump();

        // Wait for navigation to complete
        await tester.pumpAndSettle();

        // Assert - Should navigate to login screen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);

        await authId.close();
      },
    );

    testWidgets(
      'app launches, shows splash, navigates to home when authenticated',
      (WidgetTester tester) async {
        // Arrange - Mock authenticated user
        final mockUser = User(
          uid: 'test-uid',
          email: 'test@example.com',
          isAnonymous: false,
          createdAt: DateTime.now(),
        );

        final authId = StreamController<User?>.broadcast();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWith(
                (ref) => MockAuthRepository(authId.stream),
              ),
            ],
            child: const BrainVaultApp(),
          ),
        );

        // Act - emit user
        authId.add(mockUser);

        // Act - Wait for initial frame
        await tester.pump();

        // Act - Wait for navigation to complete
        await tester.pumpAndSettle();

        // Assert - Should navigate to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);

        await authId.close();
      },
    );

    testWidgets('user logs in, navigates to home', (WidgetTester tester) async {
      // Arrange - Start with no user
      final authStateController = StreamController<User?>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) => MockAuthRepository(authStateController.stream),
            ),
          ],
          child: const BrainVaultApp(),
        ),
      );

      // Emit null initially
      authStateController.add(null);
      await tester.pumpAndSettle();

      // Assert - Should be on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Act - Simulate successful login
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );
      authStateController.add(mockUser);
      await tester.pumpAndSettle();

      // Assert - Should navigate to home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Cleanup
      await authStateController.close();
    });

    testWidgets('user logs out, navigates to login', (
      WidgetTester tester,
    ) async {
      // Arrange - Start with authenticated user
      final authStateController = StreamController<User?>.broadcast();
      final mockUser = User(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) => MockAuthRepository(authStateController.stream),
            ),
          ],
          child: const BrainVaultApp(),
        ),
      );

      // Emit user initially
      authStateController.add(mockUser);
      await tester.pumpAndSettle();

      // Assert - Should be on home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Act - Simulate logout
      authStateController.add(null);
      await tester.pumpAndSettle();

      // Assert - Should navigate to login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Cleanup
      await authStateController.close();
    });

    testWidgets('loading state shows splash screen', (
      WidgetTester tester,
    ) async {
      // Arrange - Mock loading state (stream never emits)
      final neverEmittingController = StreamController<User?>.broadcast();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) => MockAuthRepository(neverEmittingController.stream),
            ),
          ],
          child: const BrainVaultApp(),
        ),
      );

      // Act
      await tester.pump();

      // Assert - Should show splash screen while loading
      expect(find.byType(SplashScreen), findsOneWidget);

      // Cleanup
      await neverEmittingController.close();
    });
  });
}
