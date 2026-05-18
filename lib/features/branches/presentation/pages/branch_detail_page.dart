import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/shared/widgets/audit_status_badge.dart';
import '../../data/datasources/sucursales_remote_datasource.dart';
import '../../data/models/sucursal_dto.dart';

/// Detalle de una sucursal: nombre, región, score circular y tabla de
/// auditorías asociadas.
class BranchDetailPage extends StatefulWidget {
  final String sucursalId;
  const BranchDetailPage({super.key, required this.sucursalId});

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  final SucursalesRemoteDatasource _datasource = SucursalesRemoteDatasource();

  SucursalDto? _sucursal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSucursal();
  }

  Future<void> _loadSucursal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SucursalDto sucursal =
          await _datasource.getById(widget.sucursalId);
      if (mounted) {
        setState(() {
          _sucursal = sucursal;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go('/sucursales'),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Volver'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate700,
                  textStyle: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _ErrorCard(
        message: _error!,
        onRetry: _loadSucursal,
      );
    }

    if (_sucursal == null) {
      return _NotFound(id: widget.sucursalId);
    }

    return _BranchDetailBody(sucursal: _sucursal!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────

class _BranchDetailBody extends StatelessWidget {
  final SucursalDto sucursal;
  const _BranchDetailBody({required this.sucursal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HeroCard(sucursal: sucursal),
        const SizedBox(height: AppSpacing.xl),
        _AuditTablePlaceholder(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO con score circular
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final SucursalDto sucursal;
  const _HeroCard({required this.sucursal});

  static Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  static String _formatDate(DateTime d) {
    try {
      return DateFormat.yMMMd('es').format(d);
    } catch (_) {
      return DateFormat.yMMMd().format(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int score = sucursal.puntajePromedio.round();
    final Color color = _scoreColor(score);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      sucursal.id,
                      style: AppTypography.monoData(12).copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AuditStatusBadge(
                      estado: sucursal.activo ? 'completada' : 'vencida',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sucursal.nombre,
                  style: AppTypography.displayMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sucursal.region,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (sucursal.direccion != null) ...<Widget>[
                  _MetaRow(
                    label: 'Dirección',
                    value: sucursal.direccion!,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                _MetaRow(
                  label: 'Registrada',
                  value: _formatDate(sucursal.creadoEn),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          _ScoreRing(score: score, color: color),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE CIRCULAR (CustomPaint)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RingPainter(progress: score / 100.0, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                  fontFamily: AppTypography.headingLg.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'de 100',
                style: AppTypography.caption.copyWith(
                  color: AppColors.slate500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 12.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - stroke) / 2;

    final Paint track = Paint()
      ..color = AppColors.slate100
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    final Paint arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIT TABLE PLACEHOLDER
// Conectar cuando exista AuditoriasRemoteDatasource.getByBranch(id)
// ─────────────────────────────────────────────────────────────────────────────

class _AuditTablePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Historial de auditorías',
            style: AppTypography.headingMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Esta sucursal aún no tiene auditorías registradas.',
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADOS: Error / Not Found
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 32, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style:
                    AppTypography.bodySm.copyWith(color: AppColors.slate500)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  final String id;
  const _NotFound({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.search_off, size: 32, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.md),
            Text('Sucursal no encontrada', style: AppTypography.headingMd),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No existe ninguna sucursal con id "$id".',
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
