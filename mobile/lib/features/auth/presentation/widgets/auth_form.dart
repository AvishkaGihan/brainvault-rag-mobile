import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Registration form widget for email/password signup
/// Extends the auth form pattern with registration-specific fields
class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    ref.read(registrationFormProvider.notifier).setEmail(value);
  }

  void _onPasswordChanged(String value) {
    ref.read(registrationFormProvider.notifier).setPassword(value);
  }

  void _onConfirmPasswordChanged(String value) {
    ref.read(registrationFormProvider.notifier).setConfirmPassword(value);
  }

  void _onRegister() {
    final formState = ref.read(registrationFormProvider);
    final notifier = ref.read(registrationFormProvider.notifier);

    // Validate and focus on errors
    final emailError = notifier.validateEmail(formState.email);
    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }

    final passwordError = notifier.validatePassword(formState.password);
    if (passwordError != null) {
      _passwordFocus.requestFocus();
      return;
    }

    final confirmError = notifier.validatePasswordMatch(
      formState.password,
      formState.confirmPassword,
    );
    if (confirmError != null) {
      _confirmPasswordFocus.requestFocus();
      return;
    }

    // Proceed with registration
    ref
        .read(registrationProvider.notifier)
        .register(formState.email, formState.password);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registrationFormProvider);
    final registrationState = ref.watch(registrationProvider);
    final isLoading = registrationState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        Text('Email', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          onChanged: _onEmailChanged,
          enabled: !isLoading,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            errorText: formState.emailError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 24),

        // Password field
        Text('Password', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: true,
          onChanged: _onPasswordChanged,
          enabled: !isLoading,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
            hintText: 'At least 6 characters',
            errorText: formState.passwordError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Password must be at least 6 characters',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Confirm password field
        Text(
          'Confirm Password',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          obscureText: true,
          onChanged: _onConfirmPasswordChanged,
          enabled: !isLoading,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
            hintText: 'Re-enter your password',
            errorText: formState.confirmPasswordError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 32),

        // Create Account button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: formState.isFormValid && !isLoading ? _onRegister : null,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Create Account'),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Creating account...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
