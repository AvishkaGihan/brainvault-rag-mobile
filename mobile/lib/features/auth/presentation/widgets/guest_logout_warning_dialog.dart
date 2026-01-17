import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

/// Guest user logout warning dialog
///
/// Shows a warning about data loss for anonymous users and provides
/// three options: Create Account, Sign Out Anyway, or Cancel.
class GuestLogoutWarningDialog extends ConsumerWidget {
  const GuestLogoutWarningDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutProvider);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: const Text('Sign Out as Guest?'),
      content: const Text(
        'As a guest, signing out will delete all your data. '
        'Create an account to save your documents.',
      ),
      actions: [
        TextButton(
          onPressed: logoutState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: logoutState.isLoading
              ? null
              : () => _signOutAnyway(context, ref),
          child: const Text('Sign Out Anyway'),
        ),
        FilledButton(
          onPressed: logoutState.isLoading
              ? null
              : () {
                  final goRouter = GoRouter.of(context);
                  Navigator.of(context).pop();
                  Future.microtask(() => goRouter.push('/register'));
                },
          child: const Text('Create Account'),
        ),
      ],
    );
  }

  Future<void> _signOutAnyway(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(logoutProvider.notifier).logout();

    if (context.mounted) {
      Navigator.of(context).pop(); // Close dialog

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't sign out. Please try again.")),
        );
      }
    }
  }
}
