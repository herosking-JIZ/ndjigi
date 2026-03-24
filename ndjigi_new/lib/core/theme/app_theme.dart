// ============================================================
// CORE/THEME/APP_THEME.DART
// Thème global de l'application N'DJIGI
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Palette principale
  static const Color primary = Color(0xFF279C74); // Vert émeraude N'DJIGI
  static const Color primaryDark = Color(0xFF1A7A58);
  static const Color primaryLight = Color(0xFFE8F7F2);
  static const Color accent = Color(0xFF00C897);

  // Couleurs fonctionnelles
  static const Color error = Color(0xFFF06262); // Rouge SOS
  static const Color warning = Color(0xFFFFB547);
  static const Color success = Color(0xFF279C74);
  static const Color info = Color(0xFF4A90D9);

  // Neutres
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF0FBF7);
  static const Color divider = Color(0xFFE8ECF4);

  // Texte
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5C2);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Carte
  static const Color mapBackground = Color(0xFFE8F5ED);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color markerBlue = Color(0xFF4A90D9);
  static const Color markerGreen = Color(0xFF279C74);

  // Rôles — couleur d'accentuation par profil
  static const Color passagerColor = Color(0xFF4A90D9);
  static const Color chauffeurColor = Color(0xFF279C74);
  static const Color proprietaireColor = Color(0xFFFF8C42);
  static const Color adminColor = Color(0xFF9B59B6);

  // Navigation
  static const Color navActive = Color(0xFF279C74);
  static const Color navInactive = Color(0xFFADB5C2);
  static const Color navIndicator = Color(0xFFE8F7F2);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.navInactive,
        elevation: 20,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
      ),
    );
  }
}
