import 'package:flutter/material.dart';

class AppColors {
  // Primary (Navy)
  static const Color primary = Color(0xFF1E3A5F); // Navy Deep
  static const Color primaryLight = Color(0xFF2D5186); // Navy Soft
  static const Color primaryMuted = Color(0xFFEEF2F8); // Navy Mist

  // Surface
  static const Color surface = Color(0xFFFAFAF8); // Warm White (Light Mode)
  static const Color surfaceCard = Color(0xFFFFFFFF); // Paper White
  static const Color surfaceSubtle = Color(0xFFF4F3F0); // Linen

  // Dark Surface
  static const Color darkSurface = Color(0xFF161618); // Rich Earthy Dark
  static const Color darkCard = Color(0xFF222225); // Card background
  static const Color darkSubtle = Color(0xFF2C2C2F); // Linen variant

  // Semantic
  static const Color success = Color(0xFF3D7A5E); // Earthy Green
  static const Color successBg = Color(0xFFEDF7F2);
  static const Color warning = Color(0xFFB07D2E); // Warm Yellow/Orange
  static const Color warningBg = Color(0xFFFDF6E7);
  static const Color danger = Color(0xFFA33030); // Subdued Red
  static const Color dangerBg = Color(0xFFFDEEED);
  static const Color info = Color(0xFF2D5186); // Navy Soft
  static const Color infoBg = Color(0xFFEEF2F8);

  // Dark Semantic Backgrounds (Muted variants)
  static const Color darkSuccessBg = Color(0xFF243B30);
  static const Color darkWarningBg = Color(0xFF4B391C);
  static const Color darkDangerBg = Color(0xFF4A1F1F);
  static const Color darkInfoBg = Color(0xFF192A44);

  // Text & Borders
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost Black
  static const Color textSecondary = Color(0xFF5C5C5C); // Charcoal
  static const Color textMuted = Color(0xFF9A9A9A); // Soft Gray
  static const Color textInverse = Color(0xFFFAFAF8); // Warm White
  static const Color textInverseSecondary = Color(0xFFA1A1A5);

  static const Color border = Color(0xFFEDEDE9); // Warm Border
  static const Color darkBorder = Color(0xFF353539); // Dark Border

  // Shimmer
  static const Color shimmerBase = Color(0xFFF4F3F0); // Linen
  static const Color shimmerHighlight = Color(0xFFFFFFFF);
  static const Color darkShimmerBase = Color(0xFF2C2C2F);
  static const Color darkShimmerHighlight = Color(0xFF353539);

  // Gradients
  static const LinearGradient healthGradient = LinearGradient(
    colors: [danger, warning, success],
    begin: Alignment.bottomLeft,
    end: Alignment.bottomRight,
  );
}
