import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/chat/presentation/screens/chat_screen.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:brainvault/features/documents/presentation/providers/documents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatScreen - Story 5.1', () {
    testWidgets('should show document title when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ChatScreen(documentTitle: 'My Document')),
        ),
      );

      expect(find.text('My Document'), findsOneWidget);
    });

    testWidgets('should fall back to Chat title when document title missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ChatScreen(documentTitle: '')),
        ),
      );

      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('should disable send button when input is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatScreen())),
      );

      expect(find.text('Ask a question...'), findsOneWidget);
      final sendButton = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('should render messages when provided', (
      WidgetTester tester,
    ) async {
      final messages = [
        ChatMessage(text: 'First message'),
        ChatMessage(text: 'Second message'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: ChatScreen(messages: messages)),
        ),
      );

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('should enable send button when text is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatScreen())),
      );

      // Initially disabled
      final sendButtonBefore = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButtonBefore.onPressed, isNull);

      // Enter text
      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Test message',
      );
      await tester.pump();

      // Should be enabled
      final sendButtonAfter = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButtonAfter.onPressed, isNotNull);
    });

    testWidgets('should show New Chat menu option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatScreen())),
      );

      // Find the overflow menu icon (three dots)
      final overflowIcon = find.byIcon(Icons.more_vert);
      expect(overflowIcon, findsOneWidget);

      await tester.tap(overflowIcon);
      await tester.pumpAndSettle();

      // Verify "New Chat" menu item exists
      expect(find.text('New Chat'), findsOneWidget);
    });
  });

  group('ChatScreen - Story 5.3', () {
    final testDocument = Document(
      id: 'doc-1',
      title: 'Doc',
      fileName: 'doc.pdf',
      fileSize: 100,
      status: DocumentStatus.ready,
      createdAt: DateTime(2026, 1, 10),
    );

    ProviderScope buildScopedChat() {
      return ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => _TestDocumentsNotifier([testDocument]),
          ),
        ],
        child: const MaterialApp(home: ChatScreen(documentId: 'doc-1')),
      );
    }

    testWidgets('send button enabled after typing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChat());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Hello',
      );
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('after send clears input and shows user message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChat());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Hello there',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      expect(find.text('Hello there'), findsOneWidget);
      final inputField = tester.widget<TextField>(
        find.byKey(const Key('chat_input_field')),
      );
      expect(inputField.controller?.text ?? '', isEmpty);

      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('awaiting response disables send and shows thinking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChat());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Question',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButton.onPressed, isNull);
      expect(find.text('Thinking...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('placeholder completion re-enables send and hides thinking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChat());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Follow up',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      expect(find.text('Thinking...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Thinking...'), findsNothing);

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Next');
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('send via Enter key press (onSubmitted)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChat());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Message via Enter',
      );
      await tester.pump();

      // Simulate pressing Enter key
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      // Message should appear after pressing Enter
      expect(find.text('Message via Enter'), findsOneWidget);
      expect(find.text('Thinking...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));
    });
  });
}

class _TestDocumentsNotifier extends DocumentsNotifier {
  final List<Document> documents;

  _TestDocumentsNotifier(this.documents);

  @override
  Future<List<Document>> build() async => documents;
}
