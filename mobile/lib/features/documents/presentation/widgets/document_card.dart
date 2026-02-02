import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';

/// Document card widget for list display
class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _statusDisplay(theme.colorScheme, document.status);
    final dateText = _formatDate(document.createdAt);
    final sizeText = _formatFileSize(document.fileSize);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          document.title.isNotEmpty ? document.title : document.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateText),
              const SizedBox(height: 4),
              Text(sizeText),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(statusInfo.label),
              backgroundColor: statusInfo.background,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: statusInfo.foreground,
              ),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            // Delete button with 48dp minimum touch target
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Delete document',
                iconSize: 24,
                padding: EdgeInsets.zero,
              ),
            ),
            // Chevron button with 48dp minimum touch target
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onTap,
                tooltip: 'View document',
                iconSize: 24,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        minLeadingWidth: 0,
      ),
    );
  }

  ({String label, Color background, Color foreground}) _statusDisplay(
    ColorScheme scheme,
    DocumentStatus status,
  ) {
    switch (status) {
      case DocumentStatus.ready:
        return (
          label: 'Ready',
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        );
      case DocumentStatus.failed:
        return (
          label: 'Error',
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
      case DocumentStatus.pending:
      case DocumentStatus.uploading:
      case DocumentStatus.uploaded:
      case DocumentStatus.processing:
        return (
          label: 'Processing',
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
        );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String _formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final formatted = size >= 10 || unitIndex == 0
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(1);

    return '$formatted ${units[unitIndex]}';
  }
}
