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
  });
}
