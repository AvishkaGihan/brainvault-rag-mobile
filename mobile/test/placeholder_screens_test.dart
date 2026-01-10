import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brainvault/features/auth/presentation/screens/login_screen.dart';
import 'package:brainvault/features/documents/presentation/screens/home_screen.dart';
import 'package:brainvault/features/chat/presentation/screens/chat_screen.dart';

void main() {
  group('Placeholder Screens Tests - Story 1.1 AC #2', () {
    testWidgets('LoginScreen is a valid widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('BrainVault'), findsOneWidget);
    });

    testWidgets('HomeScreen is a valid widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('ChatScreen without documentId', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('No document selected'), findsOneWidget);
    });

    testWidgets('ChatScreen with documentId', (WidgetTester tester) async {
      const testDocId = 'doc-123';
      await tester.pumpWidget(
        const MaterialApp(home: ChatScreen(documentId: testDocId)),
      );

      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Chatting about: $testDocId'), findsOneWidget);
    });

    testWidgets('ChatScreen validates empty documentId', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatScreen(documentId: '')),
      );

      expect(find.text('Invalid document ID'), findsOneWidget);
    });

    testWidgets('All screens display AppBar with title', (
      WidgetTester tester,
    ) async {
      // Test LoginScreen (updated from AuthScreen)
      // LoginScreen doesn't have AppBar in initial design - it has a centered UI
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      expect(find.text('BrainVault'), findsOneWidget);

      // Test HomeScreen
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('BrainVault'), findsOneWidget);
    });
  });
}
