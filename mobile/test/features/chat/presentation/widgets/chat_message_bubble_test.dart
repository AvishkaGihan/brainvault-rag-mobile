import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:brainvault/features/chat/presentation/widgets/source_citation_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageBubble', () {
    testWidgets(
      'should render user message right aligned with primaryContainer color',
      (WidgetTester tester) async {
        final theme = ThemeData(useMaterial3: true);
        final message = ChatMessage(
          text: 'Hello',
          role: ChatMessageRole.user,
          createdAt: DateTime(2026, 2, 2, 14, 34),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(body: ChatMessageBubble(message: message)),
          ),
        );

        final align = tester.widget<Align>(
          find.byKey(const Key('chat_message_bubble_align')),
        );
        expect(align.alignment, Alignment.centerRight);

        final decorated = tester.widget<DecoratedBox>(
          find.byKey(const Key('chat_message_bubble_container')),
        );
        final decoration = decorated.decoration as BoxDecoration;
        expect(decoration.color, theme.colorScheme.primaryContainer);
      },
    );

    testWidgets(
      'should render AI message left aligned with surfaceVariant color',
      (WidgetTester tester) async {
        final theme = ThemeData(useMaterial3: true);
        final message = ChatMessage(
          text: 'Hello',
          role: ChatMessageRole.assistant,
          createdAt: DateTime(2026, 2, 2, 14, 34),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(body: ChatMessageBubble(message: message)),
          ),
        );

        final align = tester.widget<Align>(
          find.byKey(const Key('chat_message_bubble_align')),
        );
        expect(align.alignment, Alignment.centerLeft);

        final decorated = tester.widget<DecoratedBox>(
          find.byKey(const Key('chat_message_bubble_container')),
        );
        final decoration = decorated.decoration as BoxDecoration;
        expect(decoration.color, theme.colorScheme.surfaceContainerHighest);
      },
    );

    testWidgets('should render a non-empty timestamp', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final message = ChatMessage(
        text: 'Hello',
        role: ChatMessageRole.user,
        createdAt: DateTime(2026, 2, 2, 14, 34),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: ChatMessageBubble(message: message)),
        ),
      );

      final timestamp = tester.widget<Text>(
        find.byKey(const Key('chat_message_bubble_timestamp')),
      );
      expect(timestamp.data, isNotNull);
      expect(timestamp.data!.trim().isNotEmpty, isTrue);
    });

    testWidgets(
      'should render citation chips only for AI messages with sources',
      (WidgetTester tester) async {
        final theme = ThemeData(useMaterial3: true);
        final aiMessageWithSources = ChatMessage(
          text: 'Answer',
          role: ChatMessageRole.assistant,
          createdAt: DateTime(2026, 2, 2, 14, 34),
          sources: const [
            ChatSource(pageNumber: 1, snippet: 'Source 1'),
            ChatSource(pageNumber: 2, snippet: 'Source 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: ChatMessageBubble(message: aiMessageWithSources),
            ),
          ),
        );

        expect(find.byType(SourceCitationChip), findsNWidgets(2));

        final aiMessageWithoutSources = ChatMessage(
          text: 'Answer',
          role: ChatMessageRole.assistant,
          createdAt: DateTime(2026, 2, 2, 14, 34),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: ChatMessageBubble(message: aiMessageWithoutSources),
            ),
          ),
        );

        expect(find.byType(SourceCitationChip), findsNothing);
      },
    );

    testWidgets('should open source preview bottom sheet when chip tapped', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final aiMessageWithSources = ChatMessage(
        text: 'Answer',
        role: ChatMessageRole.assistant,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: const [ChatSource(pageNumber: 1, snippet: 'Snippet text')],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessageWithSources),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('source_chip_0')));
      await tester.pumpAndSettle();

      final sheetFinder = find.byKey(const Key('source_preview_bottom_sheet'));
      expect(sheetFinder, findsOneWidget);
      expect(
        find.descendant(of: sheetFinder, matching: find.text('Source: Page 1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetFinder, matching: find.text('Snippet text')),
        findsOneWidget,
      );
    });

    testWidgets('should show fallback text when snippet is null (AC #4)', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final aiMessageWithNullSnippet = ChatMessage(
        text: 'Answer',
        role: ChatMessageRole.assistant,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: const [ChatSource(pageNumber: 1, snippet: null)],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessageWithNullSnippet),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('source_chip_0')));
      await tester.pumpAndSettle();

      expect(find.text('Preview unavailable.'), findsOneWidget);
    });

    testWidgets('should show fallback text when snippet is empty (AC #4)', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final aiMessageWithEmptySnippet = ChatMessage(
        text: 'Answer',
        role: ChatMessageRole.assistant,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: const [ChatSource(pageNumber: 1, snippet: '')],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessageWithEmptySnippet),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('source_chip_0')));
      await tester.pumpAndSettle();

      expect(find.text('Preview unavailable.'), findsOneWidget);
    });

    testWidgets('should support dark mode automatically (AC #5)', (
      WidgetTester tester,
    ) async {
      final darkTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      );
      final aiMessageWithSources = ChatMessage(
        text: 'Answer',
        role: ChatMessageRole.assistant,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: const [ChatSource(pageNumber: 1, snippet: 'Dark mode test')],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessageWithSources),
          ),
        ),
      );

      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      expect(chip.backgroundColor, darkTheme.colorScheme.tertiaryContainer);

      await tester.tap(find.byKey(const ValueKey('source_chip_0')));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('source_preview_bottom_sheet')),
          matching: find.byType(Container).last,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, darkTheme.colorScheme.tertiaryContainer);
    });

    testWidgets('should handle long snippets with scrollable content (AC #5)', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final longSnippet = 'Lorem ipsum dolor sit amet. ' * 50;
      final aiMessageWithLongSnippet = ChatMessage(
        text: 'Answer',
        role: ChatMessageRole.assistant,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: [ChatSource(pageNumber: 1, snippet: longSnippet)],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessageWithLongSnippet),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('source_chip_0')));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('should not show chips for user messages even with sources', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: true);
      final userMessageWithSources = ChatMessage(
        text: 'Question',
        role: ChatMessageRole.user,
        createdAt: DateTime(2026, 2, 2, 14, 34),
        sources: const [ChatSource(pageNumber: 1, snippet: 'Should not show')],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ChatMessageBubble(message: userMessageWithSources),
          ),
        ),
      );

      expect(find.byType(SourceCitationChip), findsNothing);
    });
  });
}
