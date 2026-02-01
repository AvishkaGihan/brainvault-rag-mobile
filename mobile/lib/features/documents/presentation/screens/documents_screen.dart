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

class _Strings {
  static const String offlineBannerText = 'Offline - showing cached data';
  static const String requiresInternetSnackbar = 'Requires internet connection';
  static const String refreshFailedSnackbar =
      "Couldn't refresh. Please try again.";
}

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
    final showOfflineBanner = ref.watch(documentsOfflineBannerProvider);

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
          Future<void> handleRefresh() async {
            final failure = await ref
                .read(documentsProvider.notifier)
                .refreshForPullToRefresh();
            if (!context.mounted) {
              return;
            }
            if (failure is ConnectionFailure || failure is TimeoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(_Strings.refreshFailedSnackbar),
                  duration: const Duration(seconds: 5),
                ),
              );
            } else if (failure != null) {
              // Show user-friendly error message (not raw error codes)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    failure is UnknownFailure
                        ? 'Failed to refresh. Please try again.'
                        : failure.message,
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }

          final content = documents.isEmpty
              ? const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyDocuments(),
                    ),
                  ],
                )
              : DocumentList(documents: documents);

          return Column(
            children: [
              if (showOfflineBanner)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Text(
                    _Strings.offlineBannerText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: handleRefresh,
                  child: content,
                ),
              ),
            ],
          );
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
        onPressed: () {
          if (showOfflineBanner) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(_Strings.requiresInternetSnackbar)),
            );
            return;
          }
          _showUploadOptions(context);
        },
      ),
    );
  }
}
