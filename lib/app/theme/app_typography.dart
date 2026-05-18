import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Sistema tipográfico de AuditChain.
///
/// - **UI**: Inter (Google Fonts) para todo el texto de interfaz.
/// - **Datos**: JetBrains Mono (Google Fonts) para IDs, montos, hashes y
///   cualquier valor que se beneficie de ancho fijo en tablas.
///
/// Escala (todas con color slate900 por defecto; ajustar `color` en uso):
///   displayXl  32 / 600    headingLg 20 / 500    bodyLg 16 / 400
///   displayLg  28 / 600    headingMd 18 / 500    bodyMd 14 / 400
///   displayMd  24 / 500    headingSm 16 / 500    bodySm 13 / 400
///                                                caption 12 / 400
class AppTypography {
  AppTypography._();

  static const Color _ink = AppColors.slate900;

  // ───────────── Display ─────────────
  static TextStyle displayXl = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.4,
    color: _ink,
  );

  static TextStyle displayLg = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
    color: _ink,
  );

  static TextStyle displayMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.2,
    color: _ink,
  );

  // ───────────── Heading ─────────────
  static TextStyle headingLg = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: _ink,
  );

  static TextStyle headingMd = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: _ink,
  );

  static TextStyle headingSm = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: _ink,
  );

  // ───────────── Body ─────────────
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: _ink,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: _ink,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: _ink,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.slate600,
  );

  // ───────────── Datos (mono) ─────────────

  /// Shorthand para texto monoespaciado (IDs, montos, hashes).
  /// Devuelve JetBrains Mono al `size` indicado, con weight 400 y color slate800.
  static TextStyle monoData(double size) => GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.slate800,
      );

  // ───────────── Aliases M3 (nombres de slot de TextTheme) ─────────────
  // Usados por AppSidebar, AppTopbar y otros widgets que referencian
  // los slots por nombre Material 3 en lugar de la escala semántica propia.
  static TextStyle get titleLarge => headingMd;
  static TextStyle get titleMedium => headingSm;
  static TextStyle get titleSmall => headingSm;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => bodySm;
  static TextStyle get labelLarge => bodyMd.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get labelMedium => bodySm.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get labelSmall => caption;

  /// TextTheme listo para inyectar en ThemeData (Material 3).
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayXl,
        displayMedium: displayLg,
        displaySmall: displayMd,
        headlineMedium: headingLg,
        headlineSmall: headingMd,
        titleLarge: headingMd,
        titleMedium: headingSm,
        titleSmall: headingSm,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: bodyMd.copyWith(fontWeight: FontWeight.w500),
        labelMedium: bodySm.copyWith(fontWeight: FontWeight.w500),
        labelSmall: caption,
      );
}
