import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatScreen - Story 5.1', () {
    testWidgets('should show document title when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatScreen(documentTitle: 'My Document')),
      );

      expect(find.text('My Document'), findsOneWidget);
    });

    testWidgets('should fall back to Chat title when document title missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatScreen(documentTitle: '')),
      );

      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('should disable send button when input is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

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
        MaterialApp(home: ChatScreen(messages: messages)),
      );

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('should enable send button when text is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

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
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      // Find the overflow menu icon (three dots)
      final overflowIcon = find.byIcon(Icons.more_vert);
      expect(overflowIcon, findsOneWidget);

      await tester.tap(overflowIcon);
      await tester.pumpAndSettle();

      // Verify "New Chat" menu item exists
      expect(find.text('New Chat'), findsOneWidget);
    });
  });
}
