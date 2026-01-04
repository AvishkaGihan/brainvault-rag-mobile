import 'package:flutter/material.dart';
import 'package:brainvault_app/core/widgets/loading_indicator.dart';

enum ButtonType { primary, secondary, tertiary }

enum ButtonSize { small, medium, large }

enum IconPosition { leading, trailing }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final IconPosition iconPosition;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Determine functionality state
    final isEnabled = onPressed != null && !isLoading;
    final effectiveOnPressed = isEnabled ? onPressed : null;

    // Determine dimensions and text style based on size
    final double height;
    final TextStyle? textStyle;
    final EdgeInsets padding;
    final double iconSize;

    switch (size) {
      case ButtonSize.small:
        height = 36.0;
        textStyle = textTheme.labelLarge;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        iconSize = 18.0;
        break;
      case ButtonSize.medium:
        height = 48.0;
        textStyle = textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        iconSize = 20.0;
        break;
      case ButtonSize.large:
        height = 56.0;
        textStyle = textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
        padding = const EdgeInsets.symmetric(horizontal: 32.0);
        iconSize = 24.0;
        break;
    }

    // Build the child content (Label + Icon or Loading Indicator)
    Widget childContent;
    if (isLoading) {
      childContent = LoadingIndicator(
        size: size == ButtonSize.small ? LoadingSize.small : LoadingSize.medium,
        color: type == ButtonType.primary
            ? colorScheme.onPrimary
            : colorScheme.primary,
      );
    } else {
      final List<Widget> children = [];

      if (icon != null && iconPosition == IconPosition.leading) {
        children.add(
          IconTheme(
            data: IconThemeData(size: iconSize),
            child: icon!,
          ),
        );
        children.add(const SizedBox(width: 8));
      }

      children.add(Text(label, style: textStyle, textAlign: TextAlign.center));

      if (icon != null && iconPosition == IconPosition.trailing) {
        children.add(const SizedBox(width: 8));
        children.add(
          IconTheme(
            data: IconThemeData(size: iconSize),
            child: icon!,
          ),
        );
      }

      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    // Build the specific button type
    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              padding: padding,
              minimumSize: Size(0, height),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            child: childContent,
          ),
        );

      case ButtonType.secondary:
        return SizedBox(
          height: height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              padding: padding,
              minimumSize: Size(0, height),
              side: BorderSide(
                color: isEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            child: childContent,
          ),
        );

      case ButtonType.tertiary:
        return SizedBox(
          height: height,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              padding: padding,
              minimumSize: Size(0, height),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            child: childContent,
          ),
        );
    }
  }
}
