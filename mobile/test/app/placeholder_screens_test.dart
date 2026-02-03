import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';
import 'package:brainvault/features/documents/presentation/screens/documents_screen.dart';
import 'package:brainvault/features/chat/presentation/screens/chat_screen.dart';
import 'package:brainvault/features/chat/presentation/providers/chat_history_provider.dart';
import 'package:brainvault/features/chat/domain/repositories/chat_history_repository.dart';
import 'package:brainvault/features/chat/domain/entities/chat_message.dart';
import 'package:brainvault/features/documents/presentation/providers/documents_provider.dart';
import 'package:brainvault/features/documents/presentation/providers/upload_provider.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:file_picker/file_picker.dart';

class TestDocumentsNotifier extends DocumentsNotifier {
  @override
  Future<List<Document>> build() async => [];
}

class FakeFileSelectionNotifier extends FileSelectionNotifier {
  @override
  Future<PlatformFile?> build() async => null;
}

void main() {
  group('Placeholder Screens Tests - Story 1.1 AC #2', () {
    testWidgets('LoginScreen is a valid widget', (WidgetTester tester) async {
      final overrides = [
        documentsProvider.overrideWith(() => TestDocumentsNotifier()),
        fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      // LoginScreen now has email/password form instead of BrainVault title
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('HomeScreen is a valid widget', (WidgetTester tester) async {
      final overrides = [
        documentsProvider.overrideWith(() => TestDocumentsNotifier()),
        fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('BrainVault'), findsOneWidget);
    });

    testWidgets('ChatScreen without documentId', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentsProvider.overrideWith(() => TestDocumentsNotifier()),
          ],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.byKey(const Key('chat_input_field')), findsOneWidget);
    });

    testWidgets('ChatScreen with documentId', (WidgetTester tester) async {
      const testDocId = 'doc-123';
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentsProvider.overrideWith(() => TestDocumentsNotifier()),
            chatHistoryRepositoryProvider.overrideWith(
              (ref) => _FakeChatHistoryRepository(),
            ),
          ],
          child: const MaterialApp(home: ChatScreen(documentId: testDocId)),
        ),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.byKey(const Key('chat_input_field')), findsOneWidget);
    });

    testWidgets('ChatScreen validates empty documentId', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentsProvider.overrideWith(() => TestDocumentsNotifier()),
            chatHistoryRepositoryProvider.overrideWith(
              (ref) => _FakeChatHistoryRepository(),
            ),
          ],
          child: const MaterialApp(home: ChatScreen(documentId: '')),
        ),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.byKey(const Key('chat_input_field')), findsOneWidget);
    });

    testWidgets('All screens display AppBar with title', (
      WidgetTester tester,
    ) async {
      // Test LoginScreen (updated to new email/password login design)
      final overrides = [
        documentsProvider.overrideWith(() => TestDocumentsNotifier()),
        fileSelectionProvider.overrideWith(() => FakeFileSelectionNotifier()),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      // LoginScreen doesn't have AppBar
      expect(find.text('Email'), findsOneWidget);

      // Test HomeScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(home: HomeScreen()),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('BrainVault'), findsOneWidget);
    });
  });
}

class _FakeChatHistoryRepository implements ChatHistoryRepository {
  @override
  Future<List<ChatMessage>> fetchChatHistory(
    String documentId, {
    int limit = 100,
  }) async {
    return [];
  }

  @override
  Future<List<ChatMessage>> fetchOlderChatHistory(
    String documentId,
    DateTime before, {
    int limit = 100,
  }) async {
    return [];
  }
}
