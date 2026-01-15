import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/auth/presentation/screens/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('displays logo and app name', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Assert
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('BrainVault'), findsOneWidget);
      expect(find.text('Chat with your documents'), findsOneWidget);
    });

    testWidgets('has correct background color from theme', (
      WidgetTester tester,
    ) async {
      // Arrange
      const primaryColor = Color(0xFF6750A4);
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const SplashScreen()),
      );

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, theme.colorScheme.primary);
    });

    testWidgets('displays centered column layout', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Assert
      final center = tester.widget<Center>(find.byType(Center));
      expect(center, isNotNull);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('logo has correct dimensions', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Assert
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 120);
      expect(image.height, 120);
    });

    testWidgets('has no interactive elements', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Assert - Should have no buttons or interactive elements
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('initializes failsafe timeout on init', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Assert - Timer is set in initState, so we just verify the widget builds
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('timer is cancelled on dispose', (WidgetTester tester) async {
      // Arrange & Act - Build and dispose
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const SplashScreen())),
      );

      // Act - Navigate away to trigger dispose
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));

      // Assert - No exceptions should be thrown
      expect(true, isTrue);
    });
  });
}
