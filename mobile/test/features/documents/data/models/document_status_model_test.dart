import 'package:brainvault/features/documents/data/models/document_status_model.dart';
import 'package:brainvault/features/documents/domain/entities/document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentStatusModel', () {
    test('should parse processing status response', () {
      final json = {
        'documentId': 'doc123',
        'status': 'processing',
        'updatedAt': '2026-01-25T10:00:00.000Z',
      };

      final model = DocumentStatusModel.fromJson(json);

      expect(model.documentId, 'doc123');
      expect(model.status, DocumentStatus.processing);
      expect(model.updatedAt, DateTime.parse('2026-01-25T10:00:00.000Z'));
    });

    test('should map error status to failed', () {
      final json = {
        'documentId': 'doc456',
        'status': 'error',
        'errorMessage': 'Unable to process this document',
        'updatedAt': '2026-01-25T10:00:00.000Z',
      };

      final model = DocumentStatusModel.fromJson(json);

      expect(model.status, DocumentStatus.failed);
      expect(model.errorMessage, 'Unable to process this document');
    });
  });
}
