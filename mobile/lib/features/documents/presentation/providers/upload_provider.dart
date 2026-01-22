import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/document_remote_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_text_document.dart';

/// Provider for document repository
final documentRepositoryProvider = Provider<DocumentRepositoryImpl>((ref) {
  return const DocumentRepositoryImpl(DocumentRemoteDataSource());
});

/// Provider for upload document use case
final uploadDocumentUseCaseProvider = Provider<UploadDocument>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UploadDocument(repository);
});

/// Provider for upload text document use case
final uploadTextDocumentUseCaseProvider = Provider<UploadTextDocument>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UploadTextDocument(repository);
});

/// Notifier for managing selected file state
class FileSelectionNotifier extends AsyncNotifier<PlatformFile?> {
  @override
  Future<PlatformFile?> build() async {
    return null;
  }

  /// Pick a PDF file from device storage
  Future<void> pickPdfFile() async {
    state = const AsyncLoading();

    try {
      final useCase = ref.watch(uploadDocumentUseCaseProvider);
      final file = await useCase();
      state = AsyncData(file);
    } on FilePickerCancelledFailure {
      // User cancelled - reset to null without error
      state = const AsyncData(null);
    } on FileTooLargeFailure catch (e) {
      state = AsyncError(e, StackTrace.current);
    } on InvalidFileTypeFailure catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(UnknownFailure(e.toString()), st);
    }
  }

  /// Clear selected file
  void clearSelectedFile() {
    state = const AsyncData(null);
  }

  /// Check if a valid file is selected
  bool get hasValidFile {
    return state.asData?.value != null;
  }
}

/// Provider for FileSelectionNotifier
/// Exposes the file selection state and actions to the UI
final fileSelectionProvider =
    AsyncNotifierProvider<FileSelectionNotifier, PlatformFile?>(() {
      return FileSelectionNotifier();
    });

/// Notifier for managing text upload state
class UploadTextNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state - no upload in progress
  }

  /// Upload text document with title and content
  Future<void> uploadText(String title, String content) async {
    state = const AsyncLoading();

    try {
      final useCase = ref.read(uploadTextDocumentUseCaseProvider);
      await useCase(title: title, content: content);

      state = const AsyncData(null);
      // Navigation and success message handled by UI listening to state
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider for UploadTextNotifier
final uploadTextProvider = AsyncNotifierProvider<UploadTextNotifier, void>(() {
  return UploadTextNotifier();
});
