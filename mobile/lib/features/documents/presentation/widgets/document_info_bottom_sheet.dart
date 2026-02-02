import 'package:flutter/material.dart';

import '../../domain/entities/document.dart';

class _Strings {
  static const String documentDetails = 'Document Details';
  static const String done = 'Done';
  static const String fileSize = 'File size';
  static const String pageCount = 'Page count';
  static const String uploadDate = 'Upload date';
  static const String processingDuration = 'Processing duration';
  static const String numberOfChunks = 'Number of chunks';
  static const String processingPlaceholder = 'Processing…';
  static const String unavailablePlaceholder = '—';
}

class DocumentInfoBottomSheet extends StatelessWidget {
  final Document document;

  const DocumentInfoBottomSheet({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = document.title.isNotEmpty
        ? document.title
        : document.fileName;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _Strings.documentDetails,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(_Strings.done),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              document.fileName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: _Strings.fileSize,
              value: _formatFileSize(document.fileSize),
            ),
            _InfoRow(
              label: _Strings.pageCount,
              value: _formatOptionalInt(document.pageCount),
            ),
            _InfoRow(
              label: _Strings.uploadDate,
              value: _formatDateTime(document.createdAt),
            ),
            _InfoRow(
              label: _Strings.processingDuration,
              value: _formatProcessingDuration(),
            ),
            _InfoRow(
              label: _Strings.numberOfChunks,
              value: _formatOptionalInt(document.vectorCount),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatOptionalInt(int? value) {
    if (value == null) {
      return _processingPlaceholder();
    }
    return value.toString();
  }

  String _formatProcessingDuration() {
    final indexedAt = document.indexedAt;
    if (indexedAt != null) {
      final duration = indexedAt.difference(document.createdAt);
      return _formatDuration(duration);
    }

    if (document.extractionDurationMs != null) {
      return _formatDuration(
        Duration(milliseconds: document.extractionDurationMs!),
      );
    }

    return _processingPlaceholder();
  }

  String _processingPlaceholder() {
    if (document.status == DocumentStatus.processing ||
        document.status == DocumentStatus.pending ||
        document.status == DocumentStatus.uploading ||
        document.status == DocumentStatus.uploaded) {
      return _Strings.processingPlaceholder;
    }
    return _Strings.unavailablePlaceholder;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    }
    if (duration.inMinutes >= 1) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return '${minutes}m ${seconds}s';
    }
    final seconds = duration.inSeconds;
    return '${seconds}s';
  }

  String _formatDateTime(DateTime date) {
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
    final day = date.day;
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour:$minute';
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
