import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
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
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should display app title and description', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.text('BrainVault'), findsOneWidget);
      expect(find.text('AI-Powered Document Q&A'), findsOneWidget);
    });

    testWidgets('should display feature list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.text('Guest Mode Features:'), findsOneWidget);
      expect(find.textContaining('Upload documents'), findsOneWidget);
      expect(find.textContaining('Ask AI questions'), findsOneWidget);
      expect(find.textContaining('Get answers with citations'), findsOneWidget);
      expect(find.textContaining('No signup required'), findsOneWidget);
    });

    testWidgets('should enable button initially', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert
      expect(find.byType(FilledButton), findsOneWidget);
      // Verify button is tappable
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('should have appropriate touch target size', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginScreen())),
        ),
      );

      // Assert - Button should be at least 48dp in height
      final buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
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

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
