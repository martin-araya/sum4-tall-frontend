import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

/// Tarjeta de KPI usada en dashboards.
///
/// Muestra un [label] en mayúsculas, un [value] grande y, opcionalmente,
/// una variación [delta] con una flecha ↑/↓ teñida según [positive].
///
/// Está pensada para colocarse dentro de un [Row] usando [Expanded], por eso
/// el ancho lo decide el padre.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.positive,
  });

  final String label;
  final String value;
  final String? delta;
  final bool? positive;

  static const Color _border = AppColors.slate200;
  static const Color _labelColor = AppColors.slate500;
  static const Color _valueColor = AppColors.slate900;
  static const Color _positiveColor = AppColors.accent600;
  static const Color _negativeColor = AppColors.dangerStrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _labelColor,
              letterSpacing: 0.6,
              height: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: _valueColor,
              height: 1.1,
            ),
          ),
          if (delta != null && delta!.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.sm),
            _DeltaRow(text: delta!, positive: positive),
          ],
        ],
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.text, required this.positive});

  final String text;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = positive ?? true;
    final Color color = positive == null
        ? AppColors.slate500
        : (isPositive
            ? KpiCard._positiveColor
            : KpiCard._negativeColor);
    final IconData arrow =
        isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(arrow, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
