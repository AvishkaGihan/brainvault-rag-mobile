import 'package:flutter/material.dart';

class AppTypography {
  static const String _fontFamily = 'Roboto';

  // Light Theme Typography
  static TextTheme lightTextTheme = const TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: Color(0xFF1C1B1F),
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      height: 1.29,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    // Title styles
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.27,
      letterSpacing: 0,
      color: Color(0xFF1C1B1F),
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.15,
      color: Color(0xFF1C1B1F),
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFF1C1B1F),
    ),
    // Body styles
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.15,
      color: Color(0xFF1C1B1F),
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: Color(0xFF1C1B1F),
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: Color(0xFF1C1B1F),
    ),
    // Label styles
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFF1C1B1F),
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
      color: Color(0xFF1C1B1F),
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
      color: Color(0xFF1C1B1F),
    ),
  );

  // Dark Theme Typography
  static TextTheme darkTextTheme = const TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: Color(0xFFFFFBFE),
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      height: 1.29,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    // Title styles
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.27,
      letterSpacing: 0,
      color: Color(0xFFFFFBFE),
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.15,
      color: Color(0xFFFFFBFE),
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFFFFFBFE),
    ),
    // Body styles
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.15,
      color: Color(0xFFFFFBFE),
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: Color(0xFFFFFBFE),
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: Color(0xFFFFFBFE),
    ),
    // Label styles
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFFFFFBFE),
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
      color: Color(0xFFFFFBFE),
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
      color: Color(0xFFFFFBFE),
    ),
  );
}
