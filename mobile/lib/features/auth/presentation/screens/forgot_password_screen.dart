import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/password_reset_providers.dart';

/// Screen for password reset via email
///
/// Allows users to enter their email and receive a password reset link.
/// Firebase sends reset email if email exists, silently succeeds otherwise.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(forgotPasswordFormProvider);
    final email = formState.email.trim();

    // Set loading state
    ref.read(forgotPasswordFormProvider.notifier).setLoading(true);

    try {
      await ref.read(passwordResetProvider.notifier).sendResetEmail(email);

      // Clear loading and show success
      ref.read(forgotPasswordFormProvider.notifier).setLoading(false);

      // Always show success message (even if email doesn't exist)
      if (mounted) {
        const snackBarDuration = Duration(seconds: 4);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Reset link sent to your email. Please check your inbox.',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: snackBarDuration,
          ),
        );

        // Navigate back to login after snackbar duration + short delay for visual feedback
        Future.delayed(
          snackBarDuration + const Duration(milliseconds: 500),
          () {
            if (mounted) context.pop();
          },
        );
      }
    } catch (e) {
      // Clear loading on error
      ref.read(forgotPasswordFormProvider.notifier).setLoading(false);
      // Error is handled by the provider and shown via AsyncValue
      // The UI will automatically show the error state
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(forgotPasswordFormProvider);

    // Show error snackbar if there's an error
    ref.listen(passwordResetProvider, (previous, next) {
      if (next.hasError && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Icon
              Icon(
                Icons.lock_reset,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // Explanatory text
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email field
              TextFormField(
                initialValue: formState.email,
                enabled: !formState.isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  errorText: formState.emailError,
                ),
                onChanged: (value) {
                  ref.read(forgotPasswordFormProvider.notifier).setEmail(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const Spacer(),

              // Send button
              FilledButton(
                onPressed: formState.isFormValid ? _sendResetEmail : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: formState.isLoading
                    ? LoadingIndicator(
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : const Text('Send Reset Link'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
