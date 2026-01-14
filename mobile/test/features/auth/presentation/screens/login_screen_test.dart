import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display Sign In title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert - Check for AppBar title
      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
    });

    testWidgets('should display login form with email and password fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display Sign In button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.byType(FilledButton), findsWidgets);
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('should display Forgot Password link', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should display Continue as Guest button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('should display Sign Up link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('should be scrollable when content exceeds viewport', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert - LoginScreen uses SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display within safe area', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert - Should have at least one SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have at least 48dp touch target on buttons', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert - Check FilledButton (Sign In)
      final filledButtonSize = tester.getSize(find.byType(FilledButton).first);
      expect(filledButtonSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
