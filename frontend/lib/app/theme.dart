import 'package:flutter/material.dart';

/// SAFE_PROTOCOL - Simple Clean Theme
/// Standard map-style app with colored zone overlays

class AppColors {
  // Dark theme colors (from landing page)
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFFFF6B9D); // Pink accent
  
  // Text colors for dark theme
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textOnPrimary = Colors.white;

  // Zone colors (matching the reference image)
  static const Color dangerZone = Color(0xFFE53935); // Red
  static const Color cautionZone = Color(0xFFFFB300); // Yellow/Amber
  static const Color safeZone = Color(0xFF43A047); // Green

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Legacy light theme colors (kept for compatibility)
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  // Cyberpunk accent colors (for GlitchButton widget)
  static const Color cyberCyan = Color(0xFF00FFFF);
  static const Color neonCrimson = Color(0xFFFF003C);
  static const Color voidBlack = Color(0xFF0A0A0F);
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
