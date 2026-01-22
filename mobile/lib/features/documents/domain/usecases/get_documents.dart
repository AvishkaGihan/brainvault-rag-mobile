import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use case for retrieving all documents
/// STUB: Will be fully implemented in Story 4.1
class GetDocuments {
  final DocumentRepository _repository;

  const GetDocuments(this._repository);

  /// Get all documents for current user
  /// TODO: Implement in Story 4.1 - Document Management & Library
  Future<List<Document>> call() async {
    // Stub implementation - returns empty list
    return await _repository.getDocuments();
  }
}
