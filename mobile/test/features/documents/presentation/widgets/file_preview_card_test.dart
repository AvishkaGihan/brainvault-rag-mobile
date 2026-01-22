import 'package:brainvault/features/documents/presentation/widgets/file_preview_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilePreviewCard', () {
    testWidgets('should display file information correctly', (tester) async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'test_document.pdf',
        size: 2 * 1024 * 1024, // 2MB
        path: '/path/to/test_document.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePreviewCard(
              file: mockFile,
              onUpload: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify file name
      expect(find.text('test_document.pdf'), findsOneWidget);

      // Verify file size (2.00 MB)
      expect(find.text('2.00 MB'), findsOneWidget);

      // Verify PDF icon
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);

      // Verify buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should call onUpload when Continue button is tapped', (
      tester,
    ) async {
      // Arrange
      bool uploadCalled = false;
      final mockFile = PlatformFile(
        name: 'test.pdf',
        size: 1024,
        path: '/path/to/test.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePreviewCard(
              file: mockFile,
              onUpload: () {
                uploadCalled = true;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(uploadCalled, true);
    });

    testWidgets('should call onCancel when Cancel button is tapped', (
      tester,
    ) async {
      // Arrange
      bool cancelCalled = false;
      final mockFile = PlatformFile(
        name: 'test.pdf',
        size: 1024,
        path: '/path/to/test.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePreviewCard(
              file: mockFile,
              onUpload: () {},
              onCancel: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(cancelCalled, true);
    });

    testWidgets('should format large file sizes correctly', (tester) async {
      // Arrange
      final mockFile = PlatformFile(
        name: 'large.pdf',
        size: 4500000, // ~4.29 MB
        path: '/path/to/large.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePreviewCard(
              file: mockFile,
              onUpload: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify formatted size
      expect(find.text('4.29 MB'), findsOneWidget);
    });
  });
}
