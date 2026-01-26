import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document.dart';
import '../../domain/entities/document_status.dart';

/// Processing status card widget
class ProcessingStatusCard extends StatelessWidget {
  final AsyncValue<DocumentStatusInfo?> statusState;
  final VoidCallback onRetry;
  final VoidCallback? onDone;

  const ProcessingStatusCard({
    super.key,
    required this.statusState,
    required this.onRetry,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return statusState.when(
      data: (status) {
        if (status == null) {
          return const SizedBox.shrink();
        }

        switch (status.status) {
          case DocumentStatus.processing:
          case DocumentStatus.uploading:
          case DocumentStatus.uploaded:
          case DocumentStatus.pending:
            return _buildProcessingCard(context);
          case DocumentStatus.ready:
            return _buildSuccessCard(context);
          case DocumentStatus.failed:
            return _buildErrorCard(
              context,
              status.errorMessage ?? 'Unable to process this document.',
            );
        }
      },
      loading: () => _buildProcessingCard(context),
      error: (error, _) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildProcessingCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Processing...', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'We are preparing your document for chat.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(label: 'Processing', color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    Icons.check_circle,
                    key: const ValueKey('ready'),
                    color: theme.colorScheme.tertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready for chat',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your document is processed and ready.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: 'Ready', color: theme.colorScheme.tertiary),
              ],
            ),
            if (onDone != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onDone, child: const Text('Done')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Processing failed',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _StatusBadge(label: 'Error', color: theme.colorScheme.error),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onRetry, child: const Text('Retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
