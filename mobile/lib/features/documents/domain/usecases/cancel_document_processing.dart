import '../repositories/document_repository.dart';

/// Use case for cancelling a document upload or processing
class CancelDocumentProcessing {
  final DocumentRepository _repository;

  const CancelDocumentProcessing(this._repository);

  Future<void> call(String documentId) async {
    await _repository.cancelDocumentProcessing(documentId);
  }
}
