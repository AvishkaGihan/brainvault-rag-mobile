import 'package:file_picker/file_picker.dart';

import '../entities/document.dart';

/// Abstract repository for document operations
abstract class DocumentRepository {
  /// Pick a PDF file from device storage and validate it
  /// Returns the selected file if valid, or throws a failure
  Future<PlatformFile> pickAndValidateFile();

  /// Upload document to server (to be implemented in Story 3.3)
  Future<Document> uploadDocument(PlatformFile file);

  /// Upload text document to server (placeholder for Story 3.3)
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  });

  /// Get all documents for current user (to be implemented in Story 4.1)
  Future<List<Document>> getDocuments();

  /// Delete a document (to be implemented in Story 4.5)
  Future<void> deleteDocument(String documentId);
}
