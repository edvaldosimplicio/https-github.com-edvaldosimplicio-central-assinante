import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;
  final String fontFamily;

  AppTheme({
    this.primaryColor = const Color(0xFF1A2744),
    this.secondaryColor = const Color(0xFF2E7D32),
    this.backgroundColor = const Color(0xFFF5F6FA),
    this.cardColor = Colors.white,
    this.successColor = const Color(0xFF4CAF50),
    this.warningColor = const Color(0xFFFFA726),
    this.errorColor = const Color(0xFFEF5350),
    this.textPrimary = const Color(0xFF1A2744),
    this.textSecondary = const Color(0xFF6B7280),
    this.surfaceColor = const Color(0xFFF0F4FF),
    this.fontFamily = 'Inter',
  });

  ThemeData toThemeData() {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,
      textTheme: GoogleFonts.getTextTheme(
        fontFamily,
        TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
