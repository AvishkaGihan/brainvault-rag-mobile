import 'package:flutter/material.dart';
import 'package:brainvault_app/core/widgets/app_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: colorScheme.error),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16.0),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
