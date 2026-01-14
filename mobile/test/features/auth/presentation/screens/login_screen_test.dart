import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('LoginScreen Widget Tests', () {
    // Helper function to reduce boilerplate
    Widget createLoginScreen() {
      return const ProviderScope(
        child: MaterialApp(home: Scaffold(body: LoginScreen())),
      );
    }

    testWidgets('should display Sign In title in AppBar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      final titleText = (appBar.title as Text).data;
      expect(titleText, 'Sign In');
    });

    testWidgets('should display login form with email and password fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert - AuthForm widget contains these fields
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display Sign In button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.byType(FilledButton), findsWidgets);
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('should display Forgot Password link', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('should show snackbar when Forgot Password is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      final forgotPasswordButton = find.text('Forgot Password?');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Password reset coming soon. Please contact support.'),
        findsOneWidget,
      );
    });

    testWidgets('should display Continue as Guest button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('should display Sign Up link with prompt text', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('should display Sign Up link that can be interacted with', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - Scroll to make Sign Up link visible
      await tester.dragUntilVisible(
        find.text('Sign Up'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Assert - Sign Up link should be visible and tappable
      expect(find.text('Sign Up'), findsOneWidget);
      final signUpText = tester.widget<Text>(find.text('Sign Up'));
      expect(signUpText, isNotNull);
    });

    testWidgets('should be scrollable when content exceeds viewport', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert - LoginScreen uses SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display within safe area', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert - Should have at least one SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have at least 48dp touch target on buttons', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert - Check FilledButton (Sign In)
      final filledButtonSize = tester.getSize(find.byType(FilledButton).first);
      expect(filledButtonSize.height, greaterThanOrEqualTo(48.0));

      // Assert - Check OutlinedButton (Continue as Guest)
      final outlinedButtonSize = tester.getSize(
        find.byType(OutlinedButton).first,
      );
      expect(outlinedButtonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should display divider between form and guest option', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
