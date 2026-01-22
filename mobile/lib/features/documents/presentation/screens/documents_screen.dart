import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/documents_provider.dart';
import '../widgets/empty_documents.dart';
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
          // TODO: Show document list when documents exist (Story 4.1)
          return const EmptyDocuments();
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorView(
          title: 'Error loading documents',
          message: error.toString(),
          type: ErrorViewType.generic,
        ),
      ),
      floatingActionButton: UploadFab(
        onPressed: () => _showUploadOptions(context),
      ),
    );
  }
}
