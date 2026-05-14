import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type system.
///
/// - Display: Instrument Serif (italic) — sıcak, insancıl başlıklar
/// - UI: Geist — modern, okunaklı gövde
/// - Eyebrow / kanıt: Geist Mono — zaman damgaları, hash, etiketler
class AppTypography {
  const AppTypography._();

  static TextStyle display({
    double size = 32,
    Color color = AppColors.ink,
    double height = 1.1,
  }) {
    return GoogleFonts.instrumentSerif(
      fontStyle: FontStyle.italic,
      fontSize: size,
      height: height,
      color: color,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double height = 1.4,
    double letter = -0.1,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letter < 0 ? 0 : letter,
    );
  }

  static TextStyle mono({
    double size = 10.5,
    Color color = AppColors.inkMute,
    double letter = 1.6,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letter,
    );
  }

  static TextStyle eyebrow({Color color = AppColors.inkMute}) =>
      mono(size: 10, color: color, letter: 1.8);

  /// Returns a [TextTheme] tuned for Ebeveyn Köprüsü.
  static TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge: display(size: 48),
      displayMedium: display(size: 40),
      displaySmall: display(size: 32),
      headlineLarge: display(size: 28),
      headlineMedium: display(size: 24, height: 1.15),
      headlineSmall: display(size: 20, height: 1.2),
      titleLarge: ui(size: 16, weight: FontWeight.w600),
      titleMedium: ui(size: 14, weight: FontWeight.w600),
      titleSmall: ui(size: 12.5, weight: FontWeight.w600),
      bodyLarge: ui(size: 15, weight: FontWeight.w400),
      bodyMedium: ui(size: 13.5, weight: FontWeight.w400),
      bodySmall: ui(
        size: 12,
        weight: FontWeight.w400,
        color: AppColors.inkSoft,
      ),
      labelLarge: ui(size: 13, weight: FontWeight.w600),
      labelMedium: ui(size: 11.5, weight: FontWeight.w500),
      labelSmall: mono(size: 10),
    );
  }
}
