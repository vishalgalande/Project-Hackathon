import 'package:flutter/material.dart';

/// SAFE_PROTOCOL - Simple Clean Theme
/// Standard map-style app with colored zone overlays

class AppColors {
  // Clean, simple palette
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF2196F3);

  // Zone colors (matching the reference image)
  static const Color dangerZone = Color(0xFFE53935); // Red
  static const Color cautionZone = Color(0xFFFFB300); // Yellow/Amber
  static const Color safeZone = Color(0xFF43A047); // Green

  // Cyberpunk accent colors (for GlitchButton widget)
  static const Color cyberCyan = Color(0xFF00FFFF);
  static const Color neonCrimson = Color(0xFFFF003C);
  static const Color voidBlack = Color(0xFF0A0A0F);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.cautionZone,
        surface: AppColors.surface,
        error: AppColors.dangerZone,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// Extension for zone colors
extension ZoneColorExtension on String {
  Color get zoneColor {
    switch (toLowerCase()) {
      case 'danger':
      case 'red':
        return AppColors.dangerZone;
      case 'caution':
      case 'amber':
      case 'yellow':
        return AppColors.cautionZone;
      case 'safe':
      case 'green':
        return AppColors.safeZone;
      default:
        return AppColors.textSecondary;
    }
  }
}
