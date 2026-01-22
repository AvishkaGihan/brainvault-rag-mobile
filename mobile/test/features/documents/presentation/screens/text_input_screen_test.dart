import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/features/documents/presentation/screens/text_input_screen.dart';

void main() {
  group('TextInputScreen', () {
    testWidgets('should display title field and text area', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );

      // Assert - Check key UI elements exist
      expect(find.text('New Document'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Title + Text area
      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });

    testWidgets('should update character count as user types', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );

      // Find the text area (second TextField)
      final textFields = find.byType(TextField);
      final textArea = textFields.at(1);

      // Act - Type in text area
      await tester.enterText(textArea, 'Hello World!');
      await tester.pump();

      // Assert - Check character count updated
      expect(find.textContaining('12'), findsWidgets);
      expect(find.textContaining('50,000'), findsWidgets);
    });

    testWidgets('should disable Save button when text is empty', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );

      // Act - Find Save button
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');

      // Assert - Button should be disabled
      expect(saveButton, findsOneWidget);
      final button = tester.widget<ElevatedButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'should enable Save button when both title and text are valid',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: TextInputScreen())),
        );

        // Find text fields
        final textFields = find.byType(TextField);
        final titleField = textFields.at(0);
        final textField = textFields.at(1);

        // Act - Enter title and text
        await tester.enterText(titleField, 'My Title');
        await tester.pump();

        await tester.enterText(textField, 'This is enough text content.');
        await tester.pump();

        // Assert - Button should be enabled
        final saveButton = find.widgetWithText(ElevatedButton, 'Save');
        final button = tester.widget<ElevatedButton>(saveButton);
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('screen renders successfully', (tester) async {
      // Simple smoke test to ensure screen doesn't crash
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TextInputScreen())),
      );

      expect(find.byType(TextInputScreen), findsOneWidget);
    });
  });
}
