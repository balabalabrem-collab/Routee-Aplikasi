import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === PRIMARY: Warm Espresso Brown ===
  static const Color primary = Color(0xFF6D4C2A);
  static const Color primaryLight = Color(0xFF8B6914);
  static const Color primaryDark = Color(0xFF4A3219);
  static const Color primarySurface = Color(0xFFF5EDE3);

  // === ACCENT: Warm Amber Gold ===
  static const Color accent = Color(0xFFD4A24E);
  static const Color accentLight = Color(0xFFE8B954);
  static const Color accentSurface = Color(0xFFFFF4DB);

  // === BACKGROUNDS ===
  static const Color background = Color(0xFFFAF6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0EA);
  static const Color cardShadow = Color(0x14503820);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF2D1E0F);
  static const Color textSecondary = Color(0xFF6B5744);
  static const Color textMuted = Color(0xFFA89580);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === CATEGORY BADGES (distinct, harmonious) ===
  static const Color heritageBg = Color(0xFFFFF0D4);
  static const Color heritageFg = Color(0xFF7A4F1A);
  static const Color religiBg = Color(0xFFE8F5E9);
  static const Color religiFg = Color(0xFF2E7D32);
  static const Color culinaryBg = Color(0xFFFFF3E0);
  static const Color culinaryFg = Color(0xFFBF360C);
  static const Color umkmBg = Color(0xFFF5EDE3);
  static const Color umkmFg = Color(0xFF6D4C2A);

  // === SYSTEM ===
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE8A838);
  static const Color error = Color(0xFFD32F2F);
  static const Color divider = Color(0xFFE8DFD4);

  // === GRADIENTS ===
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
  );

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xCC000000)],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A24E), Color(0xFFB07D2A)],
  );

  // === WARM BROWN HERO GRADIENT ===
  static const Gradient brownHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A3219), Color(0xFF6D4C2A), Color(0xFF8B6914)],
  );
}
