import 'package:flutter/material.dart';

/// Paleta de colores de AuditChain.
///
/// Sistema basado en azul corporativo (primary), cian (accent) y semánticos
/// (success / warning / info / neutral) cada uno con variantes background y
/// text para chips, badges y estados. La escala slate50 → slate900 cubre
/// superficies, bordes y tipografía secundaria.
class AppColors {
  AppColors._();

  // ───────────── Primary ─────────────
  static const Color primary900 = Color(0xFF0A2540);
  static const Color primary800 = Color(0xFF1E3A8A);
  static const Color primary700 = Color(0xFF243B53);
  static const Color primary600 = Color(0xFF1E3A8A);
  static const Color primary500 = Color(0xFF2563EB);
  /// Indigo-100 — used as badge backgrounds throughout the app.
  static const Color primary100 = Color(0xFFE0E7FF);
  /// Blue-700 — used for link/email text in tables.
  static const Color primaryLink = Color(0xFF1D4ED8);

  // ───────────── Accent ─────────────
  static const Color accent500 = Color(0xFF06B6D4);
  static const Color accent700 = Color(0xFF0E7490);
  static const Color accent600 = Color(0xFF059669);

  // ───────────── Danger ─────────────
  static const Color danger = Color(0xFFEF4444);
  /// Red-600 — slightly stronger than [danger]; used for negative KPI deltas.
  static const Color dangerStrong = Color(0xFFDC2626);

  // ───────────── Success ─────────────
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);

  // ───────────── Warning ─────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  // ───────────── Info ─────────────
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoBg = Color(0xFFE0F2FE);
  static const Color infoText = Color(0xFF075985);
  /// Sky-400 — chart/icon accent for 'con_observaciones' status.
  static const Color conObs = Color(0xFF38BDF8);

  // ───────────── Neutral (semántico) ─────────────
  static const Color neutral = Color(0xFF94A3B8);
  static const Color neutralBg = Color(0xFFF1F5F9);
  static const Color neutralText = Color(0xFF475569);

  // ───────────── Slate scale ─────────────
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}
