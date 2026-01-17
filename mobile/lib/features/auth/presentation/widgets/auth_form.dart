import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/login_providers.dart';
import '../providers/registration_providers.dart';

/// Mode for the AuthForm widget - determines login vs registration behavior
enum AuthFormMode { login, register }

/// Unified authentication form widget for both login and registration
/// Uses mode parameter to switch between login and registration behavior
class AuthForm extends ConsumerStatefulWidget {
  final AuthFormMode mode;

  const AuthForm({super.key, required this.mode});

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

  bool get _isLoginMode => widget.mode == AuthFormMode.login;
  bool get _isRegisterMode => widget.mode == AuthFormMode.register;

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
    if (_isLoginMode) {
      ref.read(loginFormProvider.notifier).setEmail(value);
    } else {
      ref.read(registrationFormProvider.notifier).setEmail(value);
    }
  }

  void _onPasswordChanged(String value) {
    if (_isLoginMode) {
      ref.read(loginFormProvider.notifier).setPassword(value);
    } else {
      ref.read(registrationFormProvider.notifier).setPassword(value);
    }
  }

  void _onConfirmPasswordChanged(String value) {
    ref.read(registrationFormProvider.notifier).setConfirmPassword(value);
  }

  void _onSubmit() {
    if (_isLoginMode) {
      _onSignIn();
    } else {
      _onRegister();
    }
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
    // Watch the appropriate form state based on mode
    final emailError = _isLoginMode
        ? ref.watch(loginFormProvider).emailError
        : ref.watch(registrationFormProvider).emailError;

    final passwordError = _isLoginMode
        ? ref.watch(loginFormProvider).passwordError
        : ref.watch(registrationFormProvider).passwordError;

    final confirmPasswordError = _isRegisterMode
        ? ref.watch(registrationFormProvider).confirmPasswordError
        : null;

    final isFormValid = _isLoginMode
        ? ref.watch(loginFormProvider).isFormValid
        : ref.watch(registrationFormProvider).isFormValid;

    final isLoading = _isLoginMode
        ? ref.watch(loginProvider).isLoading
        : ref.watch(registrationProvider).isLoading;

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
            errorText: emailError,
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
          autovalidateMode: _isRegisterMode
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          decoration: InputDecoration(
            hintText: _isLoginMode
                ? 'Enter your password'
                : 'At least 6 characters',
            errorText: passwordError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        // Password hint for registration mode
        if (_isRegisterMode) ...[
          const SizedBox(height: 8),
          Text(
            'Password must be at least 6 characters',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 24),

        // Confirm password field (registration only)
        if (_isRegisterMode) ...[
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
              errorText: confirmPasswordError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ] else
          const SizedBox(height: 8),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: isFormValid && !isLoading ? _onSubmit : null,
            child: isLoading
                ? const LoadingIndicator(size: 24, color: Colors.white)
                : Text(_isLoginMode ? 'Sign In' : 'Create Account'),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              _isLoginMode ? 'Signing in...' : 'Creating account...',
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
