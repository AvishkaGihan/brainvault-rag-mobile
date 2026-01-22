import 'package:flutter/material.dart';

/// Floating Action Button for document upload
class UploadFab extends StatelessWidget {
  final VoidCallback onPressed;

  const UploadFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Upload Document',
      child: const Icon(Icons.add),
    );
  }
}
