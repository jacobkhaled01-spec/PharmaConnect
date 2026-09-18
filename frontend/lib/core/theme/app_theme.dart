import 'package:flutter/material.dart';

class PharmaTheme {
  // ألوان الهوية الطبية المعتمدة (Medical Green & White Palette)
  static const Color primaryGreen = Color(0xFF059669);       // الأخضر الزمردي الرئيسي
  static const Color primaryGreenLight = Color(0xFF10B981);  // الأخضر الحيوي
  static const Color primaryGreenDark = Color(0xFF065F46);   // الأخضر الداكن
  static const Color mintBackground = Color(0xFFECFDF5);    // خلفية ناعمة
  static const Color mintAccent = Color(0xFFD1FAE5);        // شارات التوفر
  static const Color surfaceWhite = Color(0xFFFFFFFF);      // أسطح البطاقات النقية
  static const Color backgroundLight = Color(0xFFF8FAFC);   // خلفية التطبيق العامة
  static const Color textMain = Color(0xFF0F172A);          // نصوص رئيسية
  static const Color textMuted = Color(0xFF64748B);         // نصوص ثانوية
  static const Color statusWarning = Color(0xFFD97706);     // وشيك النفاذ
  static const Color statusDanger = Color(0xFFDC2626);      // غير متوفر

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryGreenLight,
        surface: surfaceWhite,
        error: statusDanger,
        onPrimary: Colors.white,
        onSurface: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryGreenDark),
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
