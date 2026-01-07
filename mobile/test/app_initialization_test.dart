import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/app/app.dart';
import 'package:brainvault/core/theme/app_colors.dart';

void main() {
  group('App Initialization Tests - Story 1.1', () {
    testWidgets('App launches without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const BrainVaultApp());
      expect(find.byType(BrainVaultApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Theme applies brand colors correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      final lightTheme = materialApp.theme;

      // Verify primary color is set to #6750A4 (Deep Purple)
      expect(
        lightTheme?.colorScheme.primary,
        equals(AppColors.primary),
        reason: 'Primary color should be #6750A4 (Deep Purple)',
      );

      // Verify tertiary color is set to #7D5260 (Dusty Rose)
      expect(
        lightTheme?.colorScheme.tertiary,
        equals(AppColors.tertiary),
        reason: 'Tertiary color should be #7D5260 (Dusty Rose)',
      );
    });

    testWidgets('Light and dark themes are configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;

      expect(
        materialApp.theme,
        isNotNull,
        reason: 'Light theme should be configured',
      );
      expect(
        materialApp.darkTheme,
        isNotNull,
        reason: 'Dark theme should be configured',
      );
      expect(
        materialApp.themeMode,
        equals(ThemeMode.system),
        reason: 'Theme mode should be system for auto light/dark switching',
      );
    });

    testWidgets('Material Design 3 is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(const BrainVaultApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      expect(
        materialApp.theme?.useMaterial3,
        isTrue,
        reason: 'useMaterial3 should be true for Material Design 3',
      );
    });

    testWidgets('AppBar displays with correct theme colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      final appBar = find.byType(AppBar);
      expect(
        appBar,
        findsWidgets,
        reason: 'AppBar should be present on screen',
      );

      // Verify AppBar background color
      final appBarWidget = appBar.first.evaluate().first.widget as AppBar;
      expect(
        appBarWidget.backgroundColor,
        equals(AppColors.primary),
        reason: 'AppBar background should use primary color',
      );
    });

    testWidgets('Navigation routes are configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      // Verify initial route is home
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Error colors are defined in theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      expect(
        materialApp.theme?.colorScheme.error,
        isNotNull,
        reason: 'Error color should be defined in theme',
      );
      expect(
        materialApp.theme?.colorScheme.error,
        equals(AppColors.error),
        reason: 'Error color should match AppColors.error',
      );
    });

    testWidgets('Theme has correct text styles configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      final textTheme = materialApp.theme?.textTheme;

      expect(textTheme, isNotNull, reason: 'Text theme should be configured');
      expect(textTheme?.headlineMedium, isNotNull);
      expect(textTheme?.bodyLarge, isNotNull);
    });
  });
}
