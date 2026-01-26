import 'package:brainvault/features/documents/data/models/document_model.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentModel', () {
    test('should create DocumentModel from PlatformFile', () {
      // Arrange
      final platformFile = PlatformFile(
        name: 'test_document.pdf',
        size: 2 * 1024 * 1024, // 2MB
        path: '/path/to/test_document.pdf',
      );

      // Act
      final model = DocumentModel.fromPlatformFile(platformFile);

      // Assert
      expect(model.fileName, 'test_document.pdf');
      expect(model.title, 'test_document'); // PDF extension removed
      expect(model.fileSize, 2 * 1024 * 1024);
      expect(model.status, DocumentStatus.pending);
      expect(model.id, isNotEmpty);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final now = DateTime(2026, 1, 20);
      final model = DocumentModel(
        id: '123',
        title: 'Test Document',
        fileName: 'test_document.pdf',
        fileSize: 1024,
        status: DocumentStatus.ready,
        createdAt: now,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['title'], 'Test Document');
      expect(json['fileName'], 'test_document.pdf');
      expect(json['fileSize'], 1024);
      expect(json['status'], 'ready');
      expect(json['createdAt'], now.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': '456',
        'title': 'Sample PDF',
        'fileName': 'sample.pdf',
        'fileSize': 2048,
        'status': 'processing',
        'createdAt': '2026-01-20T10:00:00.000Z',
      };

      // Act
      final model = DocumentModel.fromJson(json);

      // Assert
      expect(model.id, '456');
      expect(model.title, 'Sample PDF');
      expect(model.fileName, 'sample.pdf');
      expect(model.fileSize, 2048);
      expect(model.status, DocumentStatus.processing);
    });

    test('should map backend error status to failed', () {
      // Arrange
      final json = {
        'id': '789',
        'title': 'Errored Document',
        'fileName': 'error.pdf',
        'fileSize': 1024,
        'status': 'error',
        'createdAt': '2026-01-20T10:00:00.000Z',
      };

      // Act
      final model = DocumentModel.fromJson(json);

      // Assert
      expect(model.status, DocumentStatus.failed);
    });

    test('should handle all DocumentStatus enum values', () {
      // Test all status conversions
      final statuses = [
        DocumentStatus.pending,
        DocumentStatus.uploading,
        DocumentStatus.uploaded,
        DocumentStatus.processing,
        DocumentStatus.ready,
        DocumentStatus.failed,
      ];

      for (final status in statuses) {
        final model = DocumentModel(
          id: '1',
          title: 'Test',
          fileName: 'test.pdf',
          fileSize: 1024,
          status: status,
          createdAt: DateTime.now(),
        );

        final json = model.toJson();
        final deserializedModel = DocumentModel.fromJson(json);

        expect(deserializedModel.status, status);
      }
    });
  });
}
