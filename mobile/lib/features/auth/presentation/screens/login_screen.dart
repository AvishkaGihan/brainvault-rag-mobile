import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_providers.dart';
import '../providers/login_providers.dart';
import '../providers/guest_signin_provider.dart';
import '../widgets/auth_form.dart';

/// Login screen for email/password authentication
/// Provides UI for users to log in with their email and password
/// Also displays guest and sign-up options
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Navigate to home on successful login
    ref.listen(loginProvider, (previous, next) {
      if (next.hasValue &&
          !next.isLoading &&
          isAuthenticated &&
          context.mounted) {
        GoRouter.of(context).go('/');
      }
      if (next.hasError && !next.isLoading && context.mounted) {
        final error = next.error.toString();
        _showErrorDialog(context, error, ref);
      }
    });

    // If already authenticated, navigate to home
    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) GoRouter.of(context).go('/');
      });
    }

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Logo
                Icon(
                  Icons.psychology,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 16),

                // App Title
                Text(
                  'BrainVault',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Your Second Brain',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 48),

                // Login form
                const AuthForm(mode: AuthFormMode.login),

                const SizedBox(height: 24),

                // Forgot Password link
                Center(
                  child: TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset coming soon. Please contact support.',
                        ),
                      ),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                const Divider(),
                const SizedBox(height: 24),

                // Guest login option
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: ref.watch(isSigningInProvider)
                        ? null
                        : () {
                            ref.read(guestSignInProvider.notifier).signIn();
                          },
                    child: const Text('Continue as Guest'),
                  ),
                ),

                const SizedBox(height: 48),

                // Sign up link
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => GoRouter.of(context).push('/register'),
                        child: Text(
                          'Sign Up',
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
    final isNetworkError =
        error.contains('Connection error') ||
        error.contains('Check your internet');

    final isTooManyAttempts = error.contains('Too many');

    if (isNetworkError) {
      _showNetworkErrorDialog(context, error, ref);
    } else if (isTooManyAttempts) {
      _showTooManyAttemptsDialog(context, error, ref);
    } else {
      _showGenericErrorDialog(context, error, ref);
    }
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
              // Retry - trigger login again with current form state
              final formState = ref.read(loginFormProvider);
              ref
                  .read(loginProvider.notifier)
                  .signIn(formState.email, formState.password);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showTooManyAttemptsDialog(
    BuildContext context,
    String error,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Attempts'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // AC3: Clear password field on error (security best practice)
              ref.read(loginFormProvider.notifier).setPassword('');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGenericErrorDialog(
    BuildContext context,
    String error,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // AC3: Clear password field on error (security best practice)
              ref.read(loginFormProvider.notifier).setPassword('');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
