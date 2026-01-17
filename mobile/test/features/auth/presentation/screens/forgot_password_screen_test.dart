import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen', () {
    Widget createTestApp(Widget home) {
      return ProviderScope(child: MaterialApp(home: home));
    }

    testWidgets('should render all required UI elements', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      // Assert
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
      expect(
        find.text(
          'Enter your email address and we\'ll send you a link to reset your password.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('send button should be disabled when email is empty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      final button = find.byType(FilledButton);

      // Assert
      expect(
        tester.widget<FilledButton>(button).onPressed,
        isNull,
        reason: 'Button should be disabled when email is empty',
      );
    });

    testWidgets('send button should be disabled when email format is invalid', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.pump();

      final button = find.byType(FilledButton);

      // Assert
      expect(
        tester.widget<FilledButton>(button).onPressed,
        isNull,
        reason: 'Button should be disabled when email format is invalid',
      );
    });

    testWidgets('send button should be enabled when email format is valid', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      // Enter valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.pump();

      final button = find.byType(FilledButton);

      // Assert
      expect(
        tester.widget<FilledButton>(button).onPressed,
        isNotNull,
        reason: 'Button should be enabled when email format is valid',
      );
    });

    testWidgets('should show validation error for invalid email on submit', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      // Manually trigger validation by checking field
      final textField = find.byType(TextFormField);
      final state = tester.widget<TextFormField>(textField);

      // Assert validation logic
      final validator = state.validator;
      expect(validator, isNotNull);
      expect(
        validator?.call('invalid'),
        equals('Please enter a valid email address'),
      );
    });

    testWidgets('should enable email field when not loading', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      final textField = find.byType(TextFormField);

      // Assert
      expect(tester.widget<TextFormField>(textField).enabled, isTrue);
    });

    testWidgets('email validation accepts common valid email formats', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      final validEmails = [
        'user@example.com',
        'john.doe@example.co.uk',
        'test+tag@domain.org',
        'name_123@test-domain.com',
      ];

      for (final email in validEmails) {
        await tester.enterText(find.byType(TextFormField), email);
        await tester.pump();

        final button = find.byType(FilledButton);

        // Assert
        expect(
          tester.widget<FilledButton>(button).onPressed,
          isNotNull,
          reason: 'Button should be enabled for email: $email',
        );

        // Clear for next iteration
        await tester.enterText(find.byType(TextFormField), '');
        await tester.pump();
      }
    });

    testWidgets('email validation rejects common invalid email formats', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));

      final invalidEmails = [
        'notanemail',
        'user@',
        '@example.com',
        'user @example.com',
        'user@example',
        'user@.com',
      ];

      for (final email in invalidEmails) {
        await tester.enterText(find.byType(TextFormField), email);
        await tester.pump();

        final button = find.byType(FilledButton);

        // Assert
        expect(
          tester.widget<FilledButton>(button).onPressed,
          isNull,
          reason: 'Button should be disabled for email: $email',
        );

        // Clear for next iteration
        await tester.enterText(find.byType(TextFormField), '');
        await tester.pump();
      }
    });
  });
}
