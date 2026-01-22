import '../repositories/document_repository.dart';

/// Use case for deleting a document
/// STUB: Will be fully implemented in Story 4.5
class DeleteDocument {
  final DocumentRepository _repository;

  const DeleteDocument(this._repository);

  /// Delete a document by ID
  /// TODO: Implement in Story 4.5 - Implement document deletion
  Future<void> call(String documentId) async {
    // Stub implementation - will be implemented in Story 4.5
    return await _repository.deleteDocument(documentId);
  }
}
