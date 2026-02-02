import '../repositories/document_repository.dart';

/// Use case for deleting a document
/// STUB: Will be fully implemented in Story 4.5
class DeleteDocument {
  final DocumentRepository _repository;

  const DeleteDocument(this._repository);

  /// Delete a document by ID
  Future<void> call(String documentId) async {
    return await _repository.deleteDocument(documentId);
  }
}
