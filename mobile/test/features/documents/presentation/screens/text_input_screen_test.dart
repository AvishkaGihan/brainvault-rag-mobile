import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/documents/presentation/screens/text_input_screen.dart';

void main() {
  group('TextInputScreen', () {
    testWidgets('should render without crashing', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );
      await tester.pump();

      // Assert - Screen renders
      expect(find.byType(TextInputScreen), findsOneWidget);
    });

    testWidgets('should display title in app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );
      await tester.pump();

      // Assert
      expect(find.text('New Document'), findsOneWidget);
    });

    testWidgets('should display two text input fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );
      await tester.pump();

      // Assert - Should have title field and text area
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('should display clear button in app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });

    testWidgets('should display character count text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );
      await tester.pump();

      // Assert - Character counter should be visible
      expect(find.textContaining('characters'), findsOneWidget);
    });
  });
}
