import 'package:file_picker/file_picker.dart';

import '../../domain/entities/document.dart';

/// Remote data source for document operations
/// Handles file picking and server communication
class DocumentRemoteDataSource {
  const DocumentRemoteDataSource();

  /// Pick a PDF file from device storage
  /// Returns null if user cancels
  /// Throws PlatformException on permission errors
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null) {
      return null; // User cancelled
    }

    return result.files.single;
  }

  /// Upload document to server
  /// TODO: Implement in Story 3.3 - Implement Document Upload API Endpoint
  Future<Map<String, dynamic>> uploadToServer(PlatformFile file) async {
    throw UnimplementedError('Upload will be implemented in Story 3.3');
  }

  /// Upload text document to server (placeholder for Story 3.3)
  /// Returns mock Document for now, will be replaced with actual API call
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  }) async {
    // TODO (Story 3.3): Implement actual API call to POST /api/v1/documents/text
    // For now, simulate success with delay
    await Future.delayed(const Duration(seconds: 2));

    return Document(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      fileName: '$title.txt',
      fileSize: content.length,
      status: DocumentStatus.processing,
      createdAt: DateTime.now(),
    );
  }

  /// Fetch documents from server
  /// TODO: Implement in Story 4.1 - Implement Document List Screen
  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    throw UnimplementedError('Fetch will be implemented in Story 4.1');
  }

  /// Delete document from server
  /// TODO: Implement in Story 4.5 - Implement Document Deletion
  Future<void> deleteFromServer(String documentId) async {
    throw UnimplementedError('Delete will be implemented in Story 4.5');
  }
}
