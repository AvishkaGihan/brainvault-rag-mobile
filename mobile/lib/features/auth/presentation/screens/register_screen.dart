import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/error_view.dart';
import '../providers/registration_providers.dart';
import '../widgets/auth_form.dart';

/// Registration screen for email/password signup
class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationState = ref.watch(registrationProvider);
    final isLoading = registrationState.isLoading;

    // Navigate to home on successful registration
    ref.listen(registrationProvider, (previous, next) {
      if (next.hasValue && !isLoading && context.mounted) {
        GoRouter.of(context).go('/');
      }
      if (next.hasError && !isLoading && context.mounted) {
        final error = next.error.toString();
        _showErrorDialog(context, error, ref);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Logo
                  SvgPicture.asset(
                    'assets/images/logos/logo_mark.svg',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 12),

                  // App name
                  Text(
                    'BrainVault',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Tagline
                  Text(
                    'Your Second Brain',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const AuthForm(mode: AuthFormMode.register),
                  const SizedBox(height: 12),

                  // Sign in link
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => GoRouter.of(context).pop(),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error, WidgetRef ref) {
    final isEmailAlreadyInUse = error.contains('already registered');
    final isNetworkError =
        error.contains('Connection error') ||
        error.contains('Network error') ||
        error.contains('network-request-failed');

    if (isEmailAlreadyInUse) {
      _showEmailAlreadyInUseDialog(context);
    } else if (isNetworkError) {
      _showNetworkErrorDialog(context, error, ref);
    } else {
      _showGenericErrorDialog(context, error);
    }
  }

  void _showEmailAlreadyInUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Already Registered'),
        content: const Text(
          'This email is already registered. Would you like to sign in instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Use Different Email'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).pop(); // Go back to login
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showNetworkErrorDialog(
    BuildContext context,
    String error,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => ErrorView(
        title: 'Connection Error',
        message: error,
        type: ErrorViewType.network,
        onRetry: () {
          Navigator.of(context).pop();
          // Retry - trigger registration again with current form state
          final formState = ref.read(registrationFormProvider);
          ref
              .read(registrationProvider.notifier)
              .register(formState.email, formState.password);
        },
        onDismiss: () => Navigator.of(context).pop(),
        dismissText: 'Cancel',
        retryText: 'Retry',
      ),
    );
  }

  void _showGenericErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => ErrorView(
        title: 'Registration Error',
        message: error,
        type: ErrorViewType.auth,
        onDismiss: () => Navigator.of(context).pop(),
        dismissText: 'OK',
      ),
    );
  }
}
