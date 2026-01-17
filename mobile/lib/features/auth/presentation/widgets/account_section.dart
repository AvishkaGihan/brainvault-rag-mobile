import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'logout_confirmation_dialog.dart';
import 'guest_logout_warning_dialog.dart';

/// Account section widget for settings screen
///
/// Displays the current user's email (or "Guest" for anonymous users)
/// and provides a Sign Out button that shows the appropriate logout dialog.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final isGuest = user.isAnonymous;
        final displayText = isGuest ? 'Guest' : (user.email ?? 'No email');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(isGuest ? 'Guest User' : 'Account'),
              subtitle: Text(displayText),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _showLogoutDialog(context, ref, isGuest),
            ),
            const Divider(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isGuest) {
    if (isGuest) {
      showDialog(
        context: context,
        builder: (_) => const GuestLogoutWarningDialog(),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const LogoutConfirmationDialog(),
      );
    }
  }
}
