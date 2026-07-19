// *app_theme*
// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color primaryBlue = Color(0xFF1962A1);
//   static const Color accentLightBlue = Color(0xFF90CAF9);
//   static const Color backgroundLight = Color(0xFFF8FAFC);
//   static const Color errorRed = Colors.redAccent;
//   static const Color textDark = Color(0xFF1E293B);
//   static const Color textLight = Color(0xFF64748B);

//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       scaffoldBackgroundColor: Colors.white,
//       primaryColor: primaryBlue,
//       colorScheme: const ColorScheme.light(
//         primary: primaryBlue,
//         secondary: accentLightBlue,
//         surface: Colors.white,
//         error: errorRed,
//       ),
//       fontFamily: 'Roboto',
//       textTheme: const TextTheme(
//         headlineMedium: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: textDark,
//         ),
//         titleMedium: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: textDark,
//         ),
//         bodyLarge: TextStyle(fontSize: 14, color: textDark),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppTheme {
  // --- PREMIUM APED HEALTHCARE TOKENS ---
  // Deep Trust Indigo - solid, authoritative, non-clinical feel
  static const Color primaryBlue = Color(0xFF0F4C81);
  // Healing Teal Accent - fresh, energetic color for highlights and tracking states
  static const Color accentLightBlue = Color(0xFF2EC4B6);
  // Premium medical canvas whites & soft cool greys
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;

  // Refined functional colors
  static const Color errorRed = Color(0xFFE63946);
  static const Color successGreen = Color(0xFF2A9D8F);
  static const Color warningAmber = Color(0xFFF4A261);

  // Depth-focused hierarchy text colors
  static const Color textDark = Color(0xFF1E293B); // Primary headers & values
  static const Color textMedium = Color(0xFF475569); // Secondary subheadings
  static const Color textLight = Color(0xFF94A3B8); // Captions, hints, borders

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryBlue,

      // Complete semantic color coordination mapping
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentLightBlue,
        surface: surfaceWhite,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        onError: Colors.white,
      ),

      fontFamily: 'Roboto',

      // --- PREMIUM TYPOGRAPHY SYSTEM ---
      textTheme: const TextTheme(
        // Massive, editorial hero styles (e.g., Welcome titles, dynamic scores)
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textDark,
        ),
        // Screen titles
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: textDark,
        ),
        // Section group headers
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textDark,
        ),
        // Card/Sub-module titles
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        // Standard body data blocks
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          color: textMedium,
        ),
        // Subtext / Metadata descriptions
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textLight,
        ),
      ),

      // --- COMPONENT LEVEL GLOBAL REDESIGNS ---
      // Premium Apple Health-style rounded cards
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // Modern minimalist floating input text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(
          color: textMedium,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: textLight),
      ),

      // Beautiful fluid structural buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}