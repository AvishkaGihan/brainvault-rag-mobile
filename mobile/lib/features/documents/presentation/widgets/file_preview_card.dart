import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Card displaying preview of selected file
class FilePreviewCard extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onUpload;
  final VoidCallback onCancel;

  const FilePreviewCard({
    super.key,
    required this.file,
    required this.onUpload,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileSizeMB = (file.size / (1024 * 1024)).toStringAsFixed(2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info header
            Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$fileSizeMB MB',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),

                // Upload button
                FilledButton(
                  onPressed: onUpload,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
