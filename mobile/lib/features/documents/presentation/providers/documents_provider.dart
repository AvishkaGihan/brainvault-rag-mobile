import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document.dart';
import '../../domain/usecases/get_documents.dart';
import 'upload_provider.dart';

/// Provider for get documents use case
final getDocumentsUseCaseProvider = Provider<GetDocuments>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocuments(repository);
});

/// Notifier for managing documents list state
/// STUB: Returns empty list until Story 4.1
class DocumentsNotifier extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() async {
    final useCase = ref.watch(getDocumentsUseCaseProvider);
    return await useCase();
  }

  /// Refresh documents list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getDocumentsUseCaseProvider);
      return await useCase();
    });
  }
}

/// Provider for DocumentsNotifier
/// Exposes the documents list state and actions to the UI
final documentsProvider =
    AsyncNotifierProvider<DocumentsNotifier, List<Document>>(() {
      return DocumentsNotifier();
    });
