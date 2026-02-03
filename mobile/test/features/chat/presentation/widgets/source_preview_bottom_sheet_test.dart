import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/chat/presentation/widgets/source_preview_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SourcePreviewBottomSheet', () {
    testWidgets('should render source label and snippet', (
      WidgetTester tester,
    ) async {
      const source = ChatSource(pageNumber: 3, snippet: 'Test snippet');
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      expect(find.text('Source: Page 3'), findsOneWidget);
      expect(find.text('Test snippet'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should show fallback when snippet is null', (
      WidgetTester tester,
    ) async {
      const source = ChatSource(pageNumber: 5, snippet: null);
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      expect(find.text('Preview unavailable.'), findsOneWidget);
      expect(find.text('Source: Page 5'), findsOneWidget);
    });

    testWidgets('should show fallback when snippet is empty', (
      WidgetTester tester,
    ) async {
      const source = ChatSource(pageNumber: 7, snippet: '');
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      expect(find.text('Preview unavailable.'), findsOneWidget);
    });

    testWidgets('should show fallback when snippet is whitespace only', (
      WidgetTester tester,
    ) async {
      const source = ChatSource(pageNumber: 9, snippet: '   \n  ');
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      expect(find.text('Preview unavailable.'), findsOneWidget);
    });

    testWidgets('should close when close button tapped', (
      WidgetTester tester,
    ) async {
      const source = ChatSource(pageNumber: 1, snippet: 'Test');
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) =>
                          const SourcePreviewBottomSheet(source: source),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(SourcePreviewBottomSheet), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(SourcePreviewBottomSheet), findsNothing);
    });

    testWidgets('should support dark mode', (WidgetTester tester) async {
      const source = ChatSource(pageNumber: 2, snippet: 'Dark mode snippet');
      final darkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, darkTheme.colorScheme.tertiaryContainer);
    });

    testWidgets('should make long snippets scrollable', (
      WidgetTester tester,
    ) async {
      final longSnippet = 'Lorem ipsum dolor sit amet. ' * 100;
      final source = ChatSource(pageNumber: 4, snippet: longSnippet);
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: SourcePreviewBottomSheet(source: source)),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.data, isNotEmpty);
      expect(selectableText.data!.length, greaterThan(1000));
    });
  });
}
