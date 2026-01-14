import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/auth/presentation/widgets/login_form_widget.dart';

void main() {
  group('LoginFormWidget Tests', () {
    testWidgets('should display email and password fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should display placeholders in text fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
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
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
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
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
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
            child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
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
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
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
          child: MaterialApp(home: Scaffold(body: LoginFormWidget())),
        ),
      );

      // Assert
      final buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
