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
                onCancel: () {
                  ref.read(fileSelectionProvider.notifier).clearSelectedFile();
                  Navigator.pop(context);
                },
              ),
              if (showStatusCard)
                ProcessingStatusCard(
                  statusState: statusState,
                  onRetry: () =>
                      ref.read(documentStatusProvider.notifier).retry(),
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
}
