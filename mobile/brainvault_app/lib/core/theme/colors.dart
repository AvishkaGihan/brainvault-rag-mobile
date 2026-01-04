import 'package:flutter/material.dart';

/// Defines custom semantic color constants for the application.
///
/// These colors extend the standard Material 3 [ColorScheme] to provide
/// specific semantic meanings (success, warning, info) that may not be
/// fully covered by the standard tonal palettes, or where specific brand
/// consistency is required.
///
/// Values are derived from the UX Design Specification.
class AppColors {
  // Private constructor to prevent instantiation.
  AppColors._();

  /// Semantic Success Color
  /// Used for: Upload completion, success toasts, positive status indicators.
  /// Hex: #386A20
  static const Color success = Color(0xFF386A20);

  /// Semantic Error Color
  /// Used for: Validation errors, failure toasts, destructive actions.
  /// Matches Material 3 Error token reference.
  /// Hex: #B3261E
  static const Color error = Color(0xFFB3261E);

  /// Semantic Warning Color
  /// Used for: Non-blocking alerts, caution states.
  /// Hex: #7D5700
  static const Color warning = Color(0xFF7D5700);

  /// Semantic Info Color
  /// Used for: Informational banners, help tooltips.
  /// Hex: #0062A1
  static const Color info = Color(0xFF0062A1);

  // --- Opacity Variants (Optional for overlays) ---

  /// Success color with 12% opacity (Surface overlay)
  static final Color successContainer = success.withValues(alpha: 0.12);

  /// Warning color with 12% opacity (Surface overlay)
  static final Color warningContainer = warning.withValues(alpha: 0.12);

  /// Info color with 12% opacity (Surface overlay)
  static final Color infoContainer = info.withValues(alpha: 0.12);
}
