import 'package:flutter/material.dart';

/// Types of error views for different contexts
enum ErrorViewType {
  /// Generic error with retry option
  generic,

  /// Network connection error
  network,

  /// Too many attempts error
  rateLimit,

  /// Authentication error
  auth,
}

/// A reusable error view widget
///
/// Displays error messages with appropriate icons and actions.
/// Can be used in dialogs, snackbars, or full-screen error states.
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final ErrorViewType type;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryText;
  final String? dismissText;

  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.type = ErrorViewType.generic,
    this.onRetry,
    this.onDismiss,
    this.retryText,
    this.dismissText,
  });

  IconData get _icon {
    switch (type) {
      case ErrorViewType.network:
        return Icons.wifi_off;
      case ErrorViewType.rateLimit:
        return Icons.timer_off;
      case ErrorViewType.auth:
        return Icons.lock;
      case ErrorViewType.generic:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(_icon, color: Theme.of(context).colorScheme.error, size: 48),
      title: Text(title),
      content: Text(message),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: Text(dismissText ?? 'Cancel'),
          ),
        if (onRetry != null)
          FilledButton(onPressed: onRetry, child: Text(retryText ?? 'Retry')),
      ],
    );
  }
}
