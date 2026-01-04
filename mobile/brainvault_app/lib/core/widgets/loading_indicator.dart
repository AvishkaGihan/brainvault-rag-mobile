import 'package:flutter/material.dart';

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final bool centered;

  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    double dimension;
    double strokeWidth;

    switch (size) {
      case LoadingSize.small:
        dimension = 16.0;
        strokeWidth = 2.0;
        break;
      case LoadingSize.medium:
        dimension = 24.0;
        strokeWidth = 3.0;
        break;
      case LoadingSize.large:
        dimension = 48.0;
        strokeWidth = 4.0;
        break;
    }

    Widget indicator = SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (centered) {
      return Center(child: indicator);
    }

    return indicator;
  }
}

class LinearLoadingIndicator extends StatelessWidget {
  final double? value;
  final Color? color;

  const LinearLoadingIndicator({super.key, this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return LinearProgressIndicator(
      value: value,
      backgroundColor: effectiveColor.withValues(alpha: 0.2),
      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
    );
  }
}
