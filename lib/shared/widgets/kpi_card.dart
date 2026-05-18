import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Tarjeta KPI usada en la fila superior del dashboard.
///
/// - [label]    : etiqueta superior en mayúsculas pequeñas (ej: "Cumplimiento")
/// - [value]    : número grande (ej: "91,2%")
/// - [delta]    : variación (ej: "+8,5%"). Opcional.
/// - [positive] : si delta indica mejora (verde) o empeoramiento (rojo).
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool? positive;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final deltaColor = (positive ?? true)
        ? AppColors.accent600
        : AppColors.danger;
    final deltaIcon = (positive ?? true)
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: AppColors.slate500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayLg.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(deltaIcon, size: 14, color: deltaColor),
                const SizedBox(width: 4),
                Text(
                  delta!,
                  style: AppTypography.bodySm.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
