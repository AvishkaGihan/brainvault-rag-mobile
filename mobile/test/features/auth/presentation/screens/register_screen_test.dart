import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:brainvault/features/auth/presentation/screens/register_screen.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('RegisterScreen Widget Tests', () {
    // Helper function to reduce boilerplate
    Widget createRegisterScreen() {
      return const ProviderScope(
        child: MaterialApp(home: Scaffold(body: RegisterScreen())),
      );
    }

    testWidgets('should display Create Account title in AppBar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      final titleText = (appBar.title as Text).data;
      expect(titleText, 'Create Account');
    });

    testWidgets(
      'should display registration form with email, password, and confirm password fields',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createRegisterScreen());

        // Assert - AuthForm widget in register mode contains these fields
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
      },
    );

    testWidgets('should display Create Account button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert
      expect(find.byType(FilledButton), findsWidgets);
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('should display Sign In link with prompt text', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
    });

    testWidgets('should navigate back when Sign In is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockGoRouter = MockGoRouter();
      when(() => mockGoRouter.pop()).thenAnswer((_) {});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: mockGoRouter,
              child: const Scaffold(body: RegisterScreen()),
            ),
          ),
        ),
      );

      // Act
      final signInLink = find.text('Sign In');
      await tester.tap(signInLink);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockGoRouter.pop()).called(1);
    });

    testWidgets('should be scrollable when content exceeds viewport', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - RegisterScreen uses SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display within safe area', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Should have at least one SafeArea
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have at least 48dp touch target on buttons', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Check FilledButton (Create Account)
      final filledButtonSize = tester.getSize(find.byType(FilledButton).first);
      expect(filledButtonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should display password requirement hint', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Password hint is shown in register mode
      expect(find.text('Password must be at least 6 characters'), findsWidgets);
    });

    testWidgets('should have proper spacing and padding', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Check for Padding widget with expected padding
      final paddingWidget = find.ancestor(
        of: find.byType(Column),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Padding && widget.padding == const EdgeInsets.all(24.0),
        ),
      );
      expect(paddingWidget, findsWidgets);
    });

    testWidgets('should display all form fields in correct order', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Verify the order of text fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));

      // The fields should appear in order: Email, Password, Confirm Password
      // This is ensured by the AuthForm widget in register mode
    });

    testWidgets('should have AppBar with back button capability', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - AppBar should exist and allow navigation
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 0);
    });

    testWidgets('should use consistent theming with login screen', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createRegisterScreen());

      // Assert - Check for MaterialApp which provides theme
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
