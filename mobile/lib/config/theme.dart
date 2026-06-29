import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Espresso Crema palette — rich, grounded, cafe-inspired
  static const Color primary = Color(0xFF8B6A55);       // Mid-brown button
  static const Color primaryDark = Color(0xFF5A3B2E);    // Mocha pressed
  static const Color primaryLight = Color(0xFFC9B19C);   // Latte light
  static const Color accent = Color(0xFFC08552);         // Caramel accent
  static const Color background = Color(0xFFF3E7D6);     // Foam cream bg
  static const Color surface = Color(0xFFFBF3E8);        // Oat card
  static const Color surfaceLight = Color(0xFFE0D0BC);   // Border / divider  
  static const Color textPrimary = Color(0xFF2B1B14);    // Dark bean text
  static const Color textSecondary = Color(0xFF8B6A55);  // Mid-brown muted
  static const Color success = Color(0xFF66BB6A);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF5A623);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: surfaceLight.withValues(alpha: 0.5), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFCF8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: surfaceLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: surfaceLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      dividerColor: surfaceLight,
      dialogBackgroundColor: surface,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1614),
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: Color(0xFF25211E),
        error: error,
        onPrimary: Colors.white,
        onSurface: Color(0xFFE8DDD0),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: const Color(0xFFE8DDD0),
        displayColor: const Color(0xFFE8DDD0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1614),
        foregroundColor: const Color(0xFFE8DDD0),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF25211E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF332D29), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2522),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF332D29), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF332D29), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
