import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';

/// Use case for uploading text document
/// Validates and uploads text content to create a document
class UploadTextDocument {
  final DocumentRepository _repository;

  const UploadTextDocument(this._repository);

  /// Upload text document with title and content
  /// Returns created Document entity on success
  /// Throws DocumentFailure on validation or upload errors
  Future<Document> call({
    required String title,
    required String content,
  }) async {
    return await _repository.uploadTextDocument(title: title, content: content);
  }
}
