import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/logout_provider.dart';

/// Standard logout confirmation dialog for registered users
///
/// Shows a simple confirmation dialog with Cancel and Sign Out buttons.
/// Displays a loading indicator during the logout process.
class LogoutConfirmationDialog extends ConsumerWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutProvider);

    return AlertDialog(
      title: const Text('Sign Out?'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: logoutState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: logoutState.isLoading
              ? null
              : () => _performLogout(context, ref),
          child: logoutState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign Out'),
        ),
      ],
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(logoutProvider.notifier).logout();

    if (context.mounted) {
      Navigator.of(context).pop(); // Close dialog

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't sign out. Please try again.")),
        );
      }
      // If success, GoRouter auto-redirects to /login
    }
  }
}
