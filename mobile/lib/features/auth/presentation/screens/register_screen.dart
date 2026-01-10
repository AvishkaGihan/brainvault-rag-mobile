import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
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
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthForm(),
                const SizedBox(height: 24),

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
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry - trigger registration again with current form state
              final formState = ref.read(registrationFormProvider);
              ref
                  .read(registrationProvider.notifier)
                  .register(formState.email, formState.password);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showGenericErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
