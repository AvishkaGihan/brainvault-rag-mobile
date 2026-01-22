import 'package:brainvault/features/documents/presentation/widgets/empty_documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyDocuments', () {
    testWidgets('should display empty state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyDocuments())),
      );

      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No documents yet'), findsOneWidget);
      expect(find.text('Tap + to upload your first PDF!'), findsOneWidget);

      // Verify folder icon
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('should be centered on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyDocuments())),
      );

      await tester.pumpAndSettle();

      // Verify Center widget exists
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });
  });
}
