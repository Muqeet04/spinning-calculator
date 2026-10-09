import 'package:flutter/material.dart';

class SpinColors {
  static const navyDark = Color(0xFF18214F);
  static const navyLight = Color(0xFF2A3A8C);
  static const amber = Color(0xFFF5B82E);
  static const lavenderBg = Color(0xFFF0EEF6);
  static const lavenderLight = Color(0xFFF5F3FA);
  static const cardWhite = Colors.white;
  static const textNavy = Color(0xFF18214F);
  static const textGrey = Color(0xFF6B7280);
  static const errorRed = Color(0xFFDC2626);
  static const successGreen = Color(0xFF16A34A);
  static const bodyText = Color(0xFF18214F);
}

class SpinLogicTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: SpinColors.navyDark,
      scaffoldBackgroundColor: SpinColors.lavenderBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SpinColors.navyDark,
        primary: SpinColors.navyDark,
        secondary: SpinColors.amber,
        error: SpinColors.errorRed,
        surface: SpinColors.cardWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: SpinColors.textNavy, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: SpinColors.textNavy, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: SpinColors.textNavy, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: SpinColors.textNavy, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: SpinColors.textNavy),
        bodyMedium: TextStyle(color: SpinColors.textNavy),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpinColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SpinColors.textGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: SpinColors.textGrey.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SpinColors.navyDark, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: SpinColors.cardWhite,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SpinColors.navyDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
