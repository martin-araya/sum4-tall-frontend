import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema visual de AuditChain (Material 3).
///
/// Genera el ColorScheme a partir de `primary800` como semilla y aplica
/// la tipografía Inter + escala de AppTypography. Card, AppBar, inputs y
/// botones quedan alineados con la paleta y el ritmo de espaciado.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary800,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary800,
      onPrimary: Colors.white,
      secondary: AppColors.accent500,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.slate900,
      surfaceContainerHighest: AppColors.slate50,
      outline: AppColors.slate200,
      outlineVariant: AppColors.slate100,
      error: AppColors.warningText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.slate50,
      textTheme: AppTypography.textTheme,
      primaryTextTheme: AppTypography.textTheme,

      // ───────────── AppBar ─────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.slate900,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.headingMd,
        iconTheme: const IconThemeData(color: AppColors.slate700, size: 20),
      ),

      // ───────────── Card ─────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.slate200, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ───────────── Inputs ─────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.slate400),
        labelStyle: AppTypography.bodySm.copyWith(color: AppColors.slate600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary800, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.warning),
        ),
      ),

      // ───────────── Botones ─────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary800,
          foregroundColor: Colors.white,
          textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slate800,
          side: const BorderSide(color: AppColors.slate200),
          textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary800,
          textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      // ───────────── Chips / Dividers / Tooltips ─────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutralBg,
        labelStyle: AppTypography.bodySm.copyWith(color: AppColors.neutralText),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.slate200,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.slate900,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: AppTypography.bodySm.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
