import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';

/// Badge para los estados de auditoría:
/// 'completada' | 'pendiente' | 'con_observaciones' | 'vencida'
class AuditStatusBadge extends StatelessWidget {
  final String estado;
  const AuditStatusBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final c = _colorsFor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _labelFor(estado),
        style: AppTypography.bodySm.copyWith(
          color: c.fg,
          fontWeight: FontWeight.w500,
          fontSize: 11,
          height: 1.2,
        ),
      ),
    );
  }

  static _BadgeColors _colorsFor(String estado) {
    switch (estado) {
      case 'completada':
        return const _BadgeColors(Color(0xFFD1FAE5), Color(0xFF065F46));
      case 'pendiente':
        return const _BadgeColors(Color(0xFFFEF3C7), Color(0xFF92400E));
      case 'con_observaciones':
        return const _BadgeColors(Color(0xFFE0F2FE), Color(0xFF075985));
      case 'vencida':
        return const _BadgeColors(Color(0xFFF1F5F9), Color(0xFF475569));
      default:
        return const _BadgeColors(Color(0xFFF1F5F9), Color(0xFF475569));
    }
  }

  static String _labelFor(String estado) {
    switch (estado) {
      case 'completada':
        return 'Completada';
      case 'pendiente':
        return 'Pendiente';
      case 'con_observaciones':
        return 'Con obs.';
      case 'vencida':
        return 'Vencida';
      default:
        return estado;
    }
  }
}

class _BadgeColors {
  final Color bg;
  final Color fg;
  const _BadgeColors(this.bg, this.fg);
}
