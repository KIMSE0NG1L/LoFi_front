import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000000);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color accent = Color(0xFFFBBF24);
  static const Color subtle = Color(0xFFEEECEA);
  static const Color textMuted = Color(0xFF8A8880);
  static const Color textLight = Color(0xFFB0ADA8);
  static const Color textFaint = Color(0xFFC0BDB8);
  static const Color textDark = Color(0xFF000000);
  static const Color border = Color(0x0D000000);
  static const Color borderMedium = Color(0x14000000);
  static const Color success = Color(0xFF22C55E);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'pretendard',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
          ),
          hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 14),
        ),
      );
}
