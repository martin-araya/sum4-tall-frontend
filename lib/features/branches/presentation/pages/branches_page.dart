import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/shared/widgets/audit_status_badge.dart';
import '../../data/datasources/sucursales_remote_datasource.dart';
import '../../data/models/sucursal_dto.dart';

/// Listado de sucursales auditables.
///
/// Layout:
///   - Header: título + badge conteo + botón "Nueva sucursal".
///   - Grid responsivo de tarjetas (3 / 2 / 1 columnas según ancho).
///
/// Cada tarjeta navega a `/sucursales/:id` al hacer tap.
class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  final SucursalesRemoteDatasource _datasource = SucursalesRemoteDatasource();

  List<SucursalDto> _sucursales = <SucursalDto>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSucursales();
  }

  Future<void> _loadSucursales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _datasource.getAll();
      if (mounted) {
        setState(() {
          _sucursales = page.items;
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadSucursales,
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
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BranchesHeader(
            count: _sucursales.length,
            onRefresh: _loadSucursales,
          ),
          const SizedBox(height: AppSpacing.xl),
          _BranchesGrid(sucursales: _sucursales),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesHeader extends StatelessWidget {
  final int count;
  final VoidCallback onRefresh;
  const _BranchesHeader({required this.count, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Sucursales', style: AppTypography.headingLg),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary800,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva sucursal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRID
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesGrid extends StatelessWidget {
  final List<SucursalDto> sucursales;
  const _BranchesGrid({required this.sucursales});

  @override
  Widget build(BuildContext context) {
    if (sucursales.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'No hay sucursales registradas.',
            style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final int cols = w > 1100 ? 3 : (w > 700 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sucursales.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: 240,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _BranchCard(sucursal: sucursales[index]);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  final SucursalDto sucursal;
  const _BranchCard({required this.sucursal});

  static Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final int score = sucursal.puntajePromedio.round();
    final Color color = _scoreColor(score);
    final String estadoBadge = sucursal.activo ? 'completada' : 'vencida';

    String fechaTxt;
    try {
      fechaTxt = DateFormat.yMMMd('es').format(sucursal.creadoEn);
    } catch (_) {
      fechaTxt = DateFormat.yMMMd().format(sucursal.creadoEn);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go('/sucursales/${sucursal.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      sucursal.nombre,
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AuditStatusBadge(estado: estadoBadge),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sucursal.region,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.slate100),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: color,
                        height: 1,
                        fontFamily: AppTypography.headingLg.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score promedio',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Registrada: $fechaTxt',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.slate100, width: 1),
                  ),
                ),
                child: Text(
                  'Ver detalles →',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    color: AppColors.primary800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
