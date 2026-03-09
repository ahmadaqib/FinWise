import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Outfit for UI
  static TextStyle get _baseStyle => GoogleFonts.outfit();

  // JetBrains Mono for Numbers (Kept for digital-native look)
  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.5,
  );

  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -1.0,
  );

  static TextStyle get displayLarge => _baseStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w800, // Extra Bold
    height: 1.1,
    letterSpacing: -0.02 * 40, // -0.02em
  );

  static TextStyle get display => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800, // Extra Bold
    height: 1.2,
    letterSpacing: -0.02 * 32,
  );

  static TextStyle get heading1 => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    height: 1.3,
    letterSpacing: -0.02 * 24,
  );

  static TextStyle get heading2 => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    height: 1.3,
    letterSpacing: -0.02 * 20,
  );

  static TextStyle get bodyLarge => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get body => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get caption => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get label => _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5, // Wider tracking for small caps
  );
}
