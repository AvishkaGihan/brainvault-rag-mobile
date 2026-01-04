import 'package:flutter/material.dart';

/// Defines the typography scale and text styles for the application.
///
/// This class strictly adheres to the Material Design 3 (2021) type scale.
/// It provides static [TextStyle] definitions that are mapped to the
/// global [ThemeData] in [AppTheme].
///
/// Usage:
/// Use `Theme.of(context).textTheme.<role>` in widgets.
/// e.g., `Theme.of(context).textTheme.bodyLarge`
class AppTypography {
  // Private constructor to prevent instantiation.
  AppTypography._();

  // Font weights used in the system
  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;

  // --- Display Styles ---
  // Large, short, and important text.

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: _regular,
    height: 1.12, // 64px line height / 57px font size
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: _regular,
    height: 1.16, // 52px / 45px
    letterSpacing: 0.0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: _regular,
    height: 1.22, // 44px / 36px
    letterSpacing: 0.0,
  );

  // --- Headline Styles ---
  // Primary headers on screens.

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: _regular,
    height: 1.25, // 40px / 32px
    letterSpacing: 0.0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: _regular,
    height: 1.29, // 36px / 28px
    letterSpacing: 0.0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: _regular,
    height: 1.33, // 32px / 24px
    letterSpacing: 0.0,
  );

  // --- Title Styles ---
  // Section headers and shorter, medium-emphasis text.

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: _regular,
    height: 1.27, // 28px / 22px
    letterSpacing: 0.0,
  );

  /// Used for: Document names in lists
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: _medium,
    height: 1.5, // 24px / 16px
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: _medium,
    height: 1.43, // 20px / 14px
    letterSpacing: 0.1,
  );

  // --- Body Styles ---
  // Long-form writing and standard text.

  /// Used for: Chat messages, general content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: _regular,
    height: 1.5, // 24px / 16px
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: _regular,
    height: 1.43, // 20px / 14px
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: _regular,
    height: 1.33, // 16px / 12px
    letterSpacing: 0.4,
  );

  // --- Label Styles ---
  // Smaller, utility text, captions, and timestamps.

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: _medium,
    height: 1.43, // 20px / 14px
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: _medium,
    height: 1.33, // 16px / 12px
    letterSpacing: 0.5,
  );

  /// Used for: Timestamps in chat
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: _medium,
    height: 1.45, // 16px / 11px
    letterSpacing: 0.5,
  );
}
