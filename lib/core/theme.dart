import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs & styles typographiques de DEM Smart Building Monitor.
class AppColors {
  AppColors._();

  // Couleurs de base "Mission Control"
  static const Color navy = Color(0xFF051424);
  static const Color surface = Color(0xFF0A1F35);
  static const Color surfaceLight = Color(0xFF0F2A45);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color cyanDim = Color(0xFF0E7490);

  // Couleurs sémantiques
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBright = Color(0xFFFF1744);

  // Texte
  static const Color textPrimary = Color(0xFFE6F1F8);
  static const Color textSecondary = Color(0xFF7C93A8);

  // Glassmorphism
  static Color glass = Colors.white.withOpacity(0.04);
  static Color glassBorder = Colors.white.withOpacity(0.08);
}

class AppTheme {
  AppTheme._();

  /// Typographie futuriste pour les titres / valeurs clés (style "Mission Control").
  static TextStyle displayFont({
    double fontSize = 24,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  /// Typographie technique (labels, données) style terminal.
  static TextStyle monoFont({
    double fontSize = 13,
    Color color = AppColors.textSecondary,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  /// Texte courant lisible (corps de texte).
  static TextStyle bodyFont({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.cyanDim,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashColor: AppColors.cyan.withOpacity(0.1),
      highlightColor: Colors.transparent,
    );
  }

  /// Décoration "carte vitrée" (glassmorphism) réutilisable dans toute l'app.
  static BoxDecoration glassDecoration({
    double radius = 20,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}
