import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/upload_provider.dart';

/// Bottom sheet with upload options (PDF or Text)
class UploadOptionsBottomSheet extends ConsumerWidget {
  const UploadOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Add Document',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Upload PDF option
          ListTile(
            leading: Icon(
              Icons.picture_as_pdf,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            title: const Text('Upload PDF'),
            subtitle: const Text('Select a PDF file from your device'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(fileSelectionProvider.notifier).pickPdfFile();
            },
          ),

          const SizedBox(height: 8),

          // Paste Text option (disabled - coming in Story 3.2)
          ListTile(
            leading: Icon(
              Icons.text_snippet,
              color: theme.colorScheme.secondary,
              size: 32,
            ),
            title: const Text('Paste Text'),
            subtitle: const Text('Coming soon in Story 3.2'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabled: false,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Text paste will be available in Story 3.2'),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
