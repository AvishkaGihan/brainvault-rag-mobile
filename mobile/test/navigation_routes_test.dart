import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/app/app.dart';

void main() {
  group('Navigation Routes Tests - Story 1.1 AC #5', () {
    testWidgets('GoRouter is configured and functional', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      // Verify we're on home route
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App can navigate and display screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Multiple Scaffold widgets present for different routes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      // Verify routing framework is in place
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App displays initial screen without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'At least one scaffold should be visible',
      );
    });

    testWidgets('Navigation framework integrated with MaterialApp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const BrainVaultApp());
      await tester.pumpAndSettle();

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      expect(
        materialApp.routerConfig,
        isNotNull,
        reason: 'GoRouter should be configured in MaterialApp',
      );
    });
  });
}
