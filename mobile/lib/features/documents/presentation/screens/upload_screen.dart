import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/document.dart';
import '../providers/upload_provider.dart';
import '../widgets/file_preview_card.dart';
import '../widgets/processing_status_card.dart';

/// Screen for handling file upload flow
/// Shows file preview and upload confirmation
class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileSelectionProvider);
    final statusState = ref.watch(documentStatusProvider);
    final uploadState = ref.watch(uploadPdfProvider);
    final status = statusState.asData?.value;
    final canCancelProcessing =
        status != null &&
        (status.status == DocumentStatus.processing ||
            status.status == DocumentStatus.uploading ||
            status.status == DocumentStatus.uploaded ||
            status.status == DocumentStatus.pending);
    final showStatusCard =
        statusState.isLoading ||
        statusState.hasError ||
        statusState.asData?.value != null;
    final isUploading = uploadState.isLoading;

    ref.listen<AsyncValue<Document?>>(uploadPdfProvider, (_, next) {
      next.whenOrNull(
        data: (document) {
          if (document == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload complete. Processing started.'),
            ),
          );
          ref.read(documentStatusProvider.notifier).pollStatus(document.id);
        },
        error: (error, _) {
          _showErrorSnackBar(
            context,
            error.toString(),
            onRetry: () {
              final file = ref.read(fileSelectionProvider).asData?.value;
              if (file != null) {
                ref.read(uploadPdfProvider.notifier).upload(file);
              }
            },
          );
        },
      );
    });

    // Listen for errors and show SnackBar
    ref.listen<AsyncValue<dynamic>>(fileSelectionProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          if (error is FileTooLargeFailure) {
            _showErrorSnackBar(
              context,
              error.message,
              onRetry: () =>
                  ref.read(fileSelectionProvider.notifier).pickPdfFile(),
            );
          } else if (error is InvalidFileTypeFailure) {
            _showErrorSnackBar(
              context,
              error.message,
              onRetry: () =>
                  ref.read(fileSelectionProvider.notifier).pickPdfFile(),
            );
          } else if (error is! FilePickerCancelledFailure) {
            _showErrorSnackBar(
              context,
              'An error occurred while selecting file',
              onRetry: () =>
                  ref.read(fileSelectionProvider.notifier).pickPdfFile(),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Upload Document',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(fileSelectionProvider.notifier).clearSelectedFile();
            Navigator.pop(context);
          },
        ),
      ),
      body: fileState.when(
        data: (file) {
          if (file == null) {
            return EmptyState(
              title: 'No file selected',
              message: 'Go back and select a PDF file',
              icon: Icons.upload_file,
              iconSize: 80,
            );
          }

          return Column(
            children: [
              FilePreviewCard(
                file: file,
                onUpload: () {
                  if (isUploading) return;
                  ref.read(uploadPdfProvider.notifier).upload(file);
                },
                onCancel: () async {
                  final shouldCancel = await _showCancelDialog(context);
                  if (!shouldCancel) return;

                  // Widget may have been disposed while dialog was shown
                  if (!context.mounted) return;

                  if (isUploading) {
                    ref.read(uploadPdfProvider.notifier).cancelUpload();
                  }

                  ref.read(documentStatusProvider.notifier).stopPolling();
                  ref.read(documentStatusProvider.notifier).clear();
                  ref.read(fileSelectionProvider.notifier).clearSelectedFile();
                  ref.read(uploadPdfProvider.notifier).clear();

                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
              if (showStatusCard)
                ProcessingStatusCard(
                  statusState: statusState,
                  onRetry: () =>
                      ref.read(documentStatusProvider.notifier).retry(),
                  onCancel: canCancelProcessing
                      ? () async {
                          final shouldCancel = await _showCancelDialog(context);
                          if (!shouldCancel) return;

                          // Guard against widget disposal while dialog was shown
                          if (!context.mounted) return;

                          final documentId = status.documentId;

                          ref
                              .read(documentStatusProvider.notifier)
                              .stopPolling();

                          try {
                            final cancelUseCase = ref.read(
                              cancelDocumentProcessingUseCaseProvider,
                            );
                            await cancelUseCase(documentId);

                            // Widget may have been disposed while awaiting cancellation
                            if (!context.mounted) return;

                            ref
                                .read(fileSelectionProvider.notifier)
                                .clearSelectedFile();
                            ref.read(uploadPdfProvider.notifier).clear();
                            ref.read(documentStatusProvider.notifier).clear();

                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            }
                          } catch (error) {
                            if (!context.mounted) return;

                            // Convert technical errors to user-friendly messages
                            String message = 'Failed to cancel upload';
                            if (error.toString().contains(
                              'DOCUMENT_NOT_FOUND',
                            )) {
                              message = 'Document no longer exists';
                            } else if (error.toString().contains(
                              'CANCEL_NOT_ALLOWED',
                            )) {
                              message = 'Cannot cancel completed documents';
                            } else if (error.toString().contains('timeout')) {
                              message = 'Request timed out. Please try again.';
                            } else if (error.toString().contains('network')) {
                              message = 'Network error. Check your connection.';
                            }

                            _showErrorSnackBar(
                              context,
                              message,
                              onRetry: () {},
                            );
                          }
                        }
                      : null,
                ),
              if (isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LoadingIndicator(),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingIndicator(),
              SizedBox(height: 16),
              Text('Loading file...'),
            ],
          ),
        ),
        error: (error, _) => ErrorView(
          title: 'Error',
          message: error.toString(),
          type: ErrorViewType.generic,
        ),
      ),
    );
  }

  void _showErrorSnackBar(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<bool> _showCancelDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel upload?'),
        content: const Text(
          'This will stop the upload or processing and remove any partial data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel upload'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
