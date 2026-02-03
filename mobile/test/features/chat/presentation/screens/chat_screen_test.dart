import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/chat/data/chat_api.dart';
import 'package:brainvault/features/chat/data/chat_stream_event.dart';
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

    ProviderScope buildScopedChatWithApi(ChatApi chatApi) {
      return ProviderScope(
        overrides: [
          documentsProvider.overrideWith(
            () => _TestDocumentsNotifier([testDocument]),
          ),
          chatApiProvider.overrideWith((ref) => chatApi),
        ],
        child: const MaterialApp(home: ChatScreen(documentId: 'doc-1')),
      );
    }

    ProviderScope buildScopedChat() {
      return buildScopedChatWithApi(_FakeChatApiStreamImmediate());
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

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Retry',
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

      await tester.pumpAndSettle();
    });

    testWidgets('awaiting response disables send and shows streaming cursor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildScopedChatWithApi(_FakeChatApiStreamDelayed()),
      );
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
      expect(find.byKey(const Key('chat_stream_cursor')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(const Key('chat_stream_cursor')), findsNothing);
    });

    testWidgets('assistant message appears after send', (
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
      await tester.pumpAndSettle();

      expect(find.text('Assistant reply'), findsOneWidget);
    });

    testWidgets('shows partial text during streaming before done', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildScopedChatWithApi(_FakeChatApiStreamPartial()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Stream me',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      await tester.pump();
      expect(find.textContaining('Part'), findsOneWidget);
      expect(find.byKey(const Key('chat_stream_cursor')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Partial response'), findsOneWidget);
      expect(find.byKey(const Key('chat_stream_cursor')), findsNothing);
    });

    testWidgets('citation chips appear only after stream done', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildScopedChatWithApi(_FakeChatApiStreamPartial()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Citations',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      expect(find.byKey(const ValueKey('source_chip_0')), findsNothing);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('source_chip_0')), findsOneWidget);
    });

    testWidgets('fallback path renders full response when stream fails', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildScopedChatWithApi(_FakeChatApiStreamFailure()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Fallback',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();

      await tester.pumpAndSettle();
      expect(find.text('Fallback reply'), findsOneWidget);
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
      await tester.pumpAndSettle();
    });

    testWidgets('error path shows SnackBar and re-enables send', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScopedChatWithApi(_FakeChatApiFailure()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Failure test',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Thinking...'), findsNothing);
      expect(
        find.text('Unable to get an answer right now. Please try again.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('chat_input_field')),
        'Retry',
      );
      await tester.pump();

      final sendButton = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(sendButton.onPressed, isNotNull);
    });
  });
}

class _TestDocumentsNotifier extends DocumentsNotifier {
  final List<Document> documents;

  _TestDocumentsNotifier(this.documents);

  @override
  Future<List<Document>> build() async => documents;
}

class _FakeChatApiStreamImmediate implements ChatApi {
  @override
  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    yield const ChatStreamDone(
      answer: 'Assistant reply',
      sources: [ChatSource(pageNumber: 1, snippet: 'Snippet')],
      confidence: 0.9,
    );
  }

  @override
  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    return const ChatQueryResponseData(
      answer: 'Assistant reply',
      sources: [ChatSource(pageNumber: 1, snippet: 'Snippet')],
      confidence: 0.9,
    );
  }
}

class _FakeChatApiStreamDelayed implements ChatApi {
  @override
  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    yield const ChatStreamDelta(text: 'Working');
    await Future.delayed(const Duration(milliseconds: 120));
    yield const ChatStreamDone(
      answer: 'Assistant reply',
      sources: [],
      confidence: 0.9,
    );
  }

  @override
  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    return const ChatQueryResponseData(
      answer: 'Assistant reply',
      sources: [],
      confidence: 0.9,
    );
  }
}

class _FakeChatApiStreamPartial implements ChatApi {
  @override
  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    yield const ChatStreamDelta(text: 'Part');
    await Future.delayed(const Duration(milliseconds: 150));
    yield const ChatStreamDone(
      answer: 'Partial response',
      sources: [ChatSource(pageNumber: 2, snippet: 'Snippet')],
      confidence: 0.92,
    );
  }

  @override
  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    return const ChatQueryResponseData(
      answer: 'Partial response',
      sources: [ChatSource(pageNumber: 2, snippet: 'Snippet')],
      confidence: 0.92,
    );
  }
}

class _FakeChatApiStreamFailure implements ChatApi {
  @override
  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    throw Exception('Stream not available');
  }

  @override
  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    return const ChatQueryResponseData(
      answer: 'Fallback reply',
      sources: [ChatSource(pageNumber: 3, snippet: 'Fallback')],
      confidence: 0.8,
    );
  }
}

class _FakeChatApiFailure implements ChatApi {
  @override
  Stream<ChatStreamEvent> streamDocumentChat({
    required String documentId,
    required String question,
  }) async* {
    throw Exception('Network error');
  }

  @override
  Future<ChatQueryResponseData> queryDocumentChat({
    required String documentId,
    required String question,
  }) async {
    throw Exception('Network error');
  }
}
