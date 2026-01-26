import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/document_remote_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_status.dart';
import '../../domain/usecases/get_document_status.dart';
import '../../domain/usecases/cancel_document_processing.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_pdf_document.dart';
import '../../domain/usecases/upload_text_document.dart';

/// Provider for document repository
final documentRepositoryProvider = Provider<DocumentRepositoryImpl>((ref) {
  return DocumentRepositoryImpl(
    DocumentRemoteDataSource(dioClient: DioClient()),
  );
});

/// Provider for upload document use case
final uploadDocumentUseCaseProvider = Provider<UploadDocument>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UploadDocument(repository);
});

/// Provider for PDF upload use case
final uploadPdfDocumentUseCaseProvider = Provider<UploadPdfDocument>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UploadPdfDocument(repository);
});

/// Provider for upload text document use case
final uploadTextDocumentUseCaseProvider = Provider<UploadTextDocument>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UploadTextDocument(repository);
});

/// Provider for get document status use case
final getDocumentStatusUseCaseProvider = Provider<GetDocumentStatus>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocumentStatus(repository);
});

/// Provider for cancel document processing use case
final cancelDocumentProcessingUseCaseProvider =
    Provider<CancelDocumentProcessing>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return CancelDocumentProcessing(repository);
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
class UploadTextNotifier extends AsyncNotifier<Document?> {
  @override
  Future<Document?> build() async {
    // Initial state - no upload in progress
    return null;
  }

  /// Upload text document with title and content
  Future<void> uploadText(String title, String content) async {
    state = const AsyncLoading();

    try {
      final useCase = ref.read(uploadTextDocumentUseCaseProvider);
      final document = await useCase(title: title, content: content);

      state = AsyncData(document);
      // Navigation and success message handled by UI listening to state
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

/// Provider for UploadTextNotifier
final uploadTextProvider = AsyncNotifierProvider<UploadTextNotifier, Document?>(
  () {
    return UploadTextNotifier();
  },
);

/// Notifier for managing PDF upload state
class UploadPdfNotifier extends AsyncNotifier<Document?> {
  CancelToken? _cancelToken;

  @override
  Future<Document?> build() async {
    ref.onDispose(() {
      _cancelToken?.cancel('disposed');
      _cancelToken = null;
    });
    return null;
  }

  Future<void> upload(PlatformFile file) async {
    state = const AsyncLoading();
    _cancelToken = CancelToken();

    try {
      final useCase = ref.read(uploadPdfDocumentUseCaseProvider);
      final document = await useCase(file, cancelToken: _cancelToken);
      state = AsyncData(document);
      _cancelToken = null;
    } on UploadCancelledFailure {
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      _cancelToken = null;
    }
  }

  void cancelUpload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken?.cancel('cancelled');
    }
    _cancelToken = null;
    state = const AsyncData(null);
  }

  void clear() {
    state = const AsyncData(null);
  }
}

/// Provider for UploadPdfNotifier
final uploadPdfProvider = AsyncNotifierProvider<UploadPdfNotifier, Document?>(
  () {
    return UploadPdfNotifier();
  },
);

/// Notifier for polling document status after upload
class DocumentStatusNotifier extends AsyncNotifier<DocumentStatusInfo?> {
  bool _isDisposed = false;
  String? _lastDocumentId;

  @override
  Future<DocumentStatusInfo?> build() async {
    ref.onDispose(() {
      _isDisposed = true;
    });
    return null;
  }

  Future<void> pollStatus(String documentId) async {
    _isDisposed = false;
    _lastDocumentId = documentId;
    state = const AsyncLoading();

    final useCase = ref.read(getDocumentStatusUseCaseProvider);
    final startTime = DateTime.now();

    while (!_isDisposed) {
      try {
        final status = await useCase(documentId);
        state = AsyncData(status);

        if (status.status == DocumentStatus.ready ||
            status.status == DocumentStatus.failed) {
          return;
        }

        if (DateTime.now().difference(startTime) >
            const Duration(seconds: 60)) {
          state = AsyncError(
            const TimeoutFailure(
              'Processing is taking longer than expected. Please try again.',
            ),
            StackTrace.current,
          );
          // Clear timeout state after setting error so UI can retry
          await Future.delayed(const Duration(milliseconds: 100));
          if (!_isDisposed) {
            state = const AsyncData(null);
          }
          return;
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (e, st) {
        state = AsyncError(e, st);
        return;
      }
    }
  }

  void clear() {
    state = const AsyncData(null);
  }

  void stopPolling() {
    _isDisposed = true;
    _lastDocumentId = null;
    state = const AsyncData(null);
  }

  Future<void> retry() async {
    if (_lastDocumentId == null) return;
    await pollStatus(_lastDocumentId!);
  }
}

/// Provider for DocumentStatusNotifier
final documentStatusProvider =
    AsyncNotifierProvider<DocumentStatusNotifier, DocumentStatusInfo?>(() {
      return DocumentStatusNotifier();
    });
