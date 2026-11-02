import 'package:flutter/material.dart';

class AppTheme {
  // SUVIDHA Municipal Design System Tokens
  static const Color primaryNavy = Color(0xFF0E3A52);
  static const Color secondaryTeal = Color(0xFF1B8C77);
  static const Color accentSaffron = Color(0xFFD98A2B);
  static const Color surfaceDark = Color(0xFF071532);
  static const Color backgroundCream = Color(0xFFF7F5F1);
  static const Color cardWhite = Colors.white;
  static const Color borderBeige = Color(0xFFE5DFD2);
  static const Color textMuted = Color(0xFF80A0AF);

  // Status Indicators
  static const Color statusPaid = Color(0xFF3D8D51);
  static const Color statusDue = Color(0xFFD98A2B);
  static const Color statusArrears = Color(0xFFB23A2E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundCream,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: secondaryTeal,
        tertiary: accentSaffron,
        surface: cardWhite,
        error: statusArrears,
      ),
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48), // 44px+ touch target rule
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderBeige, width: 1),
        ),
      ),
    );
  }
}
