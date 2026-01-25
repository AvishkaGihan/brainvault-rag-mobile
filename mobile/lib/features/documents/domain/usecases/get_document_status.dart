import '../entities/document_status.dart';
import '../repositories/document_repository.dart';

/// Use case for fetching document processing status
class GetDocumentStatus {
  final DocumentRepository _repository;

  const GetDocumentStatus(this._repository);

  Future<DocumentStatusInfo> call(String documentId) async {
    return await _repository.getDocumentStatus(documentId);
  }
}
