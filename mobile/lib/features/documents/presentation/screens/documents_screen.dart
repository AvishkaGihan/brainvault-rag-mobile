import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../core/error/failures.dart';
import '../providers/documents_provider.dart';
import '../widgets/empty_documents.dart';
import '../widgets/document_list.dart';
import '../widgets/upload_fab.dart';
import '../widgets/upload_options_bottom_sheet.dart';
import '../providers/upload_provider.dart';

/// Home screen displaying documents library
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const UploadOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsState = ref.watch(documentsProvider);

    // Listen for file selection and navigate to upload screen
    ref.listen(fileSelectionProvider, (_, state) {
      state.whenOrNull(
        data: (file) {
          if (file != null) {
            context.push('/upload');
          }
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'BrainVault',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: documentsState.when(
        data: (documents) {
          if (documents.isEmpty) {
            return const EmptyDocuments();
          }
          return DocumentList(documents: documents);
        },
        loading: () => const ListSkeletonLoader(),
        error: (error, stack) {
          final message = switch (error) {
            Failure(:final message) => message,
            _ => 'Something went wrong. Please try again.',
          };

          final type = switch (error) {
            ConnectionFailure() || TimeoutFailure() => ErrorViewType.network,
            SessionExpiredFailure() => ErrorViewType.auth,
            _ => ErrorViewType.generic,
          };

          return Center(
            child: ErrorView(
              title: 'Error loading documents',
              message: message,
              type: type,
              onRetry: () => ref.read(documentsProvider.notifier).refresh(),
            ),
          );
        },
      ),
      floatingActionButton: UploadFab(
        onPressed: () => _showUploadOptions(context),
      ),
    );
  }
}
