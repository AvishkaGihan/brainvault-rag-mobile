import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Login form widget for email/password signin
/// Provides email, password fields and sign in button with validation
class LoginFormWidget extends ConsumerStatefulWidget {
  const LoginFormWidget({super.key});

  @override
  ConsumerState<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends ConsumerState<LoginFormWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    ref.read(loginFormProvider.notifier).setEmail(value);
  }

  void _onPasswordChanged(String value) {
    ref.read(loginFormProvider.notifier).setPassword(value);
  }

  void _onSignIn() {
    final formState = ref.read(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    // Validate email
    final emailError = notifier.validateEmail(formState.email);
    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }

    // Validate password is not empty
    if (formState.password.isEmpty) {
      _passwordFocus.requestFocus();
      return;
    }

    // Proceed with login
    ref
        .read(loginProvider.notifier)
        .signIn(formState.email, formState.password);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final loginState = ref.watch(loginProvider);
    final isLoading = loginState.isLoading;

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
          decoration: InputDecoration(
            hintText: 'Enter your password',
            errorText: formState.passwordError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 32),

        // Sign In button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: formState.isFormValid && !isLoading ? _onSignIn : null,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Sign In'),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Signing in...',
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
