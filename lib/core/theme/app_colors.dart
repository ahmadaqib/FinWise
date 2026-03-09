import 'package:flutter/material.dart';

class AppColors {
  // Primary (Flat Blue)
  static const Color primary = Color(0xFF3B82F6); // Blue 500
  static const Color primaryLight = Color(0xFF60A5FA); // Blue 400
  static const Color primaryMuted = Color(0xFFEFF6FF); // Blue 50

  // Surface
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceCard = Color(0xFFFFFFFF); // Paper White
  static const Color surfaceSubtle = Color(0xFFF3F4F6); // Gray 100

  // Dark Surface
  static const Color darkSurface = Color(0xFF161618); // Rich Earthy Dark
  static const Color darkCard = Color(0xFF222225); // Card background
  static const Color darkSubtle = Color(0xFF2C2C2F); // Linen variant

  // Semantic (Flat)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoBg = Color(0xFFEFF6FF);

  // Dark Semantic Backgrounds (Muted variants)
  static const Color darkSuccessBg = Color(0xFF243B30);
  static const Color darkWarningBg = Color(0xFF4B391C);
  static const Color darkDangerBg = Color(0xFF4A1F1F);
  static const Color darkInfoBg = Color(0xFF192A44);

  // Text & Borders
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textInverseSecondary = Color(0xFFD1D5DB);

  static const Color border = Color(0xFFE5E7EB); // Gray 200
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
