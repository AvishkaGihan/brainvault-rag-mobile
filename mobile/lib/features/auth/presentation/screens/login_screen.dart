import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/error_view.dart';
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

                  // Login form
                  const AuthForm(mode: AuthFormMode.login),

                  const SizedBox(height: 12),

                  // Forgot Password link
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),

                  // Guest login option
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: ref.watch(isSigningInProvider)
                          ? null
                          : () {
                              ref.read(guestSignInProvider.notifier).signIn();
                            },
                      child: const Text('Continue as Guest'),
                    ),
                  ),

                  const SizedBox(height: 24),

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
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error, WidgetRef ref) {
    final isNetworkError =
        error.contains('Connection error') ||
        error.contains('Check your internet');

    final isTooManyAttempts = error.contains('Too many');

    ErrorViewType type;
    String title;
    VoidCallback? onRetry;

    if (isNetworkError) {
      type = ErrorViewType.network;
      title = 'Connection Error';
      onRetry = () {
        Navigator.of(context).pop();
        // Retry - trigger login again with current form state
        final formState = ref.read(loginFormProvider);
        ref
            .read(loginProvider.notifier)
            .signIn(formState.email, formState.password);
      };
    } else if (isTooManyAttempts) {
      type = ErrorViewType.rateLimit;
      title = 'Too Many Attempts';
      onRetry = null;
    } else {
      type = ErrorViewType.auth;
      title = 'Sign In Error';
      onRetry = null;
    }

    showDialog(
      context: context,
      builder: (context) => ErrorView(
        title: title,
        message: error,
        type: type,
        onRetry: onRetry,
        onDismiss: () {
          Navigator.of(context).pop();
          // AC3: Clear password field on error (security best practice)
          ref.read(loginFormProvider.notifier).setPassword('');
        },
        dismissText: 'OK',
      ),
    );
  }
}
