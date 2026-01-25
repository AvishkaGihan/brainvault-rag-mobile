import 'package:brainvault/features/documents/presentation/widgets/upload_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadOptionsBottomSheet', () {
    testWidgets('should display upload options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: UploadOptionsBottomSheet())),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Add Document'), findsOneWidget);

      // Verify Upload PDF option
      expect(find.text('Upload PDF'), findsOneWidget);
      expect(find.text('Select a PDF file from your device'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

      // Verify Paste Text option (disabled)
      expect(find.text('Paste Text'), findsOneWidget);
      expect(find.text('Type or paste text content directly'), findsOneWidget);
      expect(find.byIcon(Icons.text_snippet), findsOneWidget);
    });

    testWidgets('should have proper Material 3 styling', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: UploadOptionsBottomSheet())),
        ),
      );

      await tester.pumpAndSettle();

      // Verify container has rounded corners
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
