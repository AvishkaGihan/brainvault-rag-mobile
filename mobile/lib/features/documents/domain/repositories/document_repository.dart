import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../entities/document.dart';
import '../entities/document_status.dart';

/// Abstract repository for document operations
abstract class DocumentRepository {
  /// Pick a PDF file from device storage and validate it
  /// Returns the selected file if valid, or throws a failure
  Future<PlatformFile> pickAndValidateFile();

  /// Upload document to server (to be implemented in Story 3.3)
  Future<Document> uploadDocument(PlatformFile file, {CancelToken? cancelToken});

  /// Upload text document to server (implemented in Story 3.2)
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  });

  /// Get all documents for current user (to be implemented in Story 4.1)
  Future<List<Document>> getDocuments();

  /// Get processing status for a document (Story 3.8)
  /// Returns DocumentStatusInfo with status, errorMessage, progress, processingStage
  Future<DocumentStatusInfo> getDocumentStatus(String documentId);

  /// Cancel a document upload or processing request (Story 3.9)
  Future<void> cancelDocumentProcessing(String documentId);

  /// Delete a document (to be implemented in Story 4.5)
  Future<void> deleteDocument(String documentId);
}
