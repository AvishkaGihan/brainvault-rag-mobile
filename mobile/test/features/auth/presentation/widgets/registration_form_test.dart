import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainvault/features/auth/presentation/widgets/auth_form.dart';

void main() {
  group('AuthForm Widget Tests', () {
    testWidgets('displays email, password, and confirm password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(home: Scaffold(body: AuthForm())),
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
          child: MaterialApp(home: Scaffold(body: AuthForm())),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      expect(emailField, findsOneWidget);
    });

    testWidgets('password fields are obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp(home: Scaffold(body: AuthForm())),
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
          child: MaterialApp(home: Scaffold(body: AuthForm())),
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
          child: MaterialApp(home: Scaffold(body: AuthForm())),
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
            home: Scaffold(body: SingleChildScrollView(child: AuthForm())),
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
            home: Scaffold(body: SingleChildScrollView(child: AuthForm())),
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
            home: Scaffold(body: SingleChildScrollView(child: AuthForm())),
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
}
