import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

/// Implementation of DocumentRepository
/// Handles file picking, validation, and server communication
class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remoteDataSource;

  const DocumentRepositoryImpl(this._remoteDataSource);

  /// Maximum file size in bytes (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  @override
  Future<PlatformFile> pickAndValidateFile() async {
    try {
      // Pick file using data source
      final file = await _remoteDataSource.pickFile();

      // Handle user cancellation
      if (file == null) {
        throw const FilePickerCancelledFailure();
      }

      // Validate file type
      if (file.extension?.toLowerCase() != 'pdf') {
        throw const InvalidFileTypeFailure();
      }

      // Validate file size
      if (file.size > maxFileSize) {
        throw const FileTooLargeFailure();
      }

      return file;
    } on DocumentFailure {
      rethrow; // Re-throw domain failures as-is
    } catch (e) {
      // Wrap unexpected errors in UnknownFailure
      throw UnknownFailure('Failed to pick file: ${e.toString()}');
    }
  }

  @override
  Future<Document> uploadDocument(PlatformFile file) async {
    // TODO: Implement in Story 3.3
    throw UnimplementedError('Upload will be implemented in Story 3.3');
  }

  @override
  Future<Document> uploadTextDocument({
    required String title,
    required String content,
  }) async {
    try {
      // Validate title
      if (title.trim().isEmpty) {
        throw const TitleRequiredFailure();
      }

      if (title.length > 100) {
        throw const TitleTooLongFailure();
      }

      // Validate content
      if (content.trim().length < 10) {
        throw const TextTooShortFailure();
      }

      if (content.length > 50000) {
        throw const TextTooLongFailure();
      }

      // Call data source to upload
      final document = await _remoteDataSource.uploadTextDocument(
        title: title,
        content: content,
      );

      return document;
    } on DocumentFailure {
      rethrow; // Re-throw domain failures as-is
    } catch (e) {
      // Wrap unexpected errors in UnknownFailure
      throw UnknownFailure('Failed to upload text: ${e.toString()}');
    }
  }

  @override
  Future<List<Document>> getDocuments() async {
    // TODO: Implement in Story 4.1
    // Stub: return empty list
    return [];
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    // TODO: Implement in Story 4.5
    // Stub: do nothing
    return;
  }
}
