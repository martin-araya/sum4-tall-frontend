import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Badge tipo "pill" para representar el estado de una auditoría.
///
/// Mapea cada estado a un par de colores (fondo + texto) y a una etiqueta
/// legible. Los estados desconocidos caen en un estilo slate neutro.
class AuditStatusBadge extends StatelessWidget {
  const AuditStatusBadge({super.key, required this.estado});

  final String estado;

  static const Map<String, _BadgeStyle> _styles = <String, _BadgeStyle>{
    'completada': _BadgeStyle(
      background: AppColors.successBg,
      foreground: AppColors.successText,
    ),
    'pendiente': _BadgeStyle(
      background: AppColors.warningBg,
      foreground: AppColors.warningText,
    ),
    'con_observaciones': _BadgeStyle(
      background: AppColors.infoBg,
      foreground: AppColors.infoText,
    ),
    'vencida': _BadgeStyle(
      background: AppColors.neutralBg,
      foreground: AppColors.neutralText,
    ),
  };

  static String _labelFor(String estado) {
    if (estado == 'con_observaciones') return 'Con obs.';
    if (estado.isEmpty) return estado;
    final String normalized = estado.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final _BadgeStyle style = _styles[estado] ??
        const _BadgeStyle(
          background: AppColors.neutralBg,
          foreground: AppColors.neutralText,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _labelFor(estado),
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}
