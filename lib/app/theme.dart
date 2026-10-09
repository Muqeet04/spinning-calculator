import 'package:flutter/material.dart';

/// Clean Minimalist Corporate Palette
class SpinColors {
  // Deep Royal Blue Brand Dominance
  static const royalBlue = Color(0xFF1D4ED8);
  static const royalNavy = Color(0xFF0F172A);
  static const slateLight = Color(0xFF1E293B);

  // Rich Emerald Accent & Highlights
  static const emerald = Color(0xFF059669);
  static const emeraldLight = Color(0xFF10B981);
  static const emeraldGlow = Color(0xFFECFDF5);

  // Backgrounds: Crisp clean whites & cool greys
  static const pageBg = Color(0xFFF8FAFC);
  static const coolGreyBg = Color(0xFFF1F5F9);
  static const cardWhite = Colors.white;

  // Text & Borders
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF1D4ED8);

  // Status & Utility
  static const errorRed = Color(0xFFEF4444);
  static const successGreen = Color(0xFF059669);

  // Aliases for compatibility
  static const navyDark = royalNavy;
  static const navyLight = royalBlue;
  static const amber = emerald; // Upgraded secondary accent to Rich Emerald
  static const lavenderBg = pageBg;
  static const lavenderLight = coolGreyBg;
  static const textNavy = textPrimary;
  static const textGrey = textSecondary;
  static const bodyText = textPrimary;
}

class SpinLogicTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: SpinColors.royalBlue,
      scaffoldBackgroundColor: SpinColors.pageBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SpinColors.royalBlue,
        primary: SpinColors.royalBlue,
        secondary: SpinColors.emerald,
        surface: SpinColors.cardWhite,
        error: SpinColors.errorRed,
      ),
      fontFamily: 'Roboto',
      dataTableTheme: const DataTableThemeData(
        dataRowMinHeight: 64,
        dataRowMaxHeight: double.infinity,
        headingRowHeight: 64,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: SpinColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: SpinColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(color: SpinColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.2),
        titleMedium: TextStyle(color: SpinColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: SpinColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: SpinColors.textPrimary, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpinColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SpinColors.borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SpinColors.borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SpinColors.royalBlue, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: SpinColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: SpinColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SpinColors.royalBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
