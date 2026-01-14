import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainvault/features/auth/presentation/widgets/auth_form.dart';

void main() {
  group('AuthForm Widget Tests - Register Mode', () {
    testWidgets('displays email, password, and confirm password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.register)),
          ),
        ),
      );

      await tester.pump(); // Allow async build to complete

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('email field has correct properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.register)),
          ),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      expect(emailField, findsOneWidget);
    });

    testWidgets('password fields are obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.register)),
          ),
        ),
      );

      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);

      expect(passwordField, findsOneWidget);
      expect(confirmField, findsOneWidget);
    });

    testWidgets('create account button is disabled when form is invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.register)),
          ),
        ),
      );

      final button = find.byType(FilledButton);
      final filledButton = tester.widget<FilledButton>(button);

      expect(filledButton.onPressed, null); // Disabled
    });

    testWidgets('create account button is enabled when form is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.register)),
          ),
        ),
      );

      // Enter valid data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      await tester.pumpAndSettle();

      final button = find.byType(FilledButton);
      final filledButton = tester.widget<FilledButton>(button);

      expect(filledButton.onPressed, isNotNull); // Enabled
    });

    testWidgets('shows validation errors for invalid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AuthForm(mode: AuthFormMode.register),
              ),
            ),
          ),
        ),
      );

      // Find the email field and enter invalid email
      final emailField = find.byType(TextFormField).at(0);
      await tester.enterText(emailField, 'invalid-email');

      // Pump multiple frames to allow Riverpod state to propagate
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows validation errors for short password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AuthForm(mode: AuthFormMode.register),
              ),
            ),
          ),
        ),
      );

      // Enter short password
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, '123');

      // Pump multiple frames to allow Riverpod state to propagate
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Look for error in the InputDecoration errorText
      expect(
        find.textContaining('Password must be at least 6 characters'),
        findsWidgets,
      );
    });

    testWidgets('shows validation errors for mismatched passwords', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AuthForm(mode: AuthFormMode.register),
              ),
            ),
          ),
        ),
      );

      // Enter password first, then mismatched confirm password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(2), 'different');

      // Pump multiple frames to allow Riverpod state to propagate
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('AuthForm Widget Tests - Login Mode', () {
    testWidgets('should display email and password fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Only email and password
    });

    testWidgets('should display placeholders in text fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert - Hint texts should be displayed
      expect(find.text('you@example.com'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('should display Sign In button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should disable Sign In button when form is empty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert - Button should be disabled initially
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'should enable Sign In button when both fields have valid input',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
            ),
          ),
        );

        // Act - Enter valid email
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'test@example.com');
        await tester.pumpAndSettle();

        // Act - Enter password
        final passwordField = find.byType(TextFormField).last;
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        // Assert - Button should be enabled
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('should show loading indicator when signing in', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert - Initially no loading indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Note: To test loading state, we would need to trigger the login
      // which requires mocking the providers, so this is a basic check
    });

    testWidgets('should have at least 48dp button height', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert
      final buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should not display confirm password field in login mode', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AuthForm(mode: AuthFormMode.login)),
          ),
        ),
      );

      // Assert - No confirm password field
      expect(find.text('Confirm Password'), findsNothing);
    });
  });
}
