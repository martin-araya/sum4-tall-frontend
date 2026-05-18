import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/shared/widgets/audit_status_badge.dart';
import '../../data/datasources/auditorias_remote_datasource.dart';
import '../../data/models/auditoria_dto.dart';

/// Listado de auditorías con filtros por estado.
///
/// Layout:
///   - Header: título + badge con conteo filtrado.
///   - Barra horizontal de FilterChips (estado).
///   - Tabla en card blanca con filas alternadas y columnas:
///     ID | Sucursal | Auditor | Fecha | Score | Estado | —
///   - Empty state si el filtro no devuelve resultados.
class AuditsPage extends StatefulWidget {
  const AuditsPage({super.key});

  @override
  State<AuditsPage> createState() => _AuditsPageState();
}

class _AuditsPageState extends State<AuditsPage> {
  final AuditoriasRemoteDatasource _datasource = AuditoriasRemoteDatasource();

  List<AuditoriaDto> _todasAuditorias = <AuditoriaDto>[];
  bool _isLoading = true;
  String? _error;

  // 'todas' | 'pendiente' | 'completada' | 'con_observaciones' | 'vencida'
  String _filtroEstado = 'todas';

  List<AuditoriaDto> get _filtered => _filtroEstado == 'todas'
      ? _todasAuditorias
      : _todasAuditorias
          .where((AuditoriaDto a) => a.estado == _filtroEstado)
          .toList();

  @override
  void initState() {
    super.initState();
    _loadAuditorias();
  }

  Future<void> _loadAuditorias() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _datasource.getAll();
      if (mounted) {
        setState(() {
          _todasAuditorias = page.items;
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

  void _setFiltro(String value) => setState(() => _filtroEstado = value);

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
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.slate400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadAuditorias,
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

    final List<AuditoriaDto> auditorias = _filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AuditsHeader(count: auditorias.length),
          const SizedBox(height: AppSpacing.lg),
          _FilterBar(selected: _filtroEstado, onChanged: _setFiltro),
          const SizedBox(height: AppSpacing.xl),
          if (auditorias.isEmpty)
            const _EmptyState()
          else
            _AuditsTable(auditorias: auditorias),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _AuditsHeader extends StatelessWidget {
  final int count;
  const _AuditsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Auditorías', style: AppTypography.headingLg),
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
          onPressed: () => context.go('/audits/wizard'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva Auditoría'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});

  static const List<_FilterOption> _options = <_FilterOption>[
    _FilterOption('todas', 'Todas'),
    _FilterOption('pendiente', 'Pendientes'),
    _FilterOption('completada', 'Completadas'),
    _FilterOption('con_observaciones', 'Con observaciones'),
    _FilterOption('vencida', 'Vencidas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _options.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _Chip(
              label: _options[i].label,
              isSelected: selected == _options[i].value,
              selectedColor: AppColors.primary800,
              onTap: () => onChanged(_options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterOption {
  final String value;
  final String label;
  const _FilterOption(this.value, this.label);
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isSelected ? selectedColor : Colors.white;
    final Color fg = isSelected ? Colors.white : AppColors.slate700;
    final Color borderColor = isSelected ? selectedColor : AppColors.slate200;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: fg,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLA
// ─────────────────────────────────────────────────────────────────────────────

// Flex por columna: ID | Sucursal | Auditor | Fecha | Score | Estado | More
const List<int> _kAuditColFlex = <int>[2, 4, 3, 2, 1, 2, 1];

class _AuditsTable extends StatelessWidget {
  final List<AuditoriaDto> auditorias;
  const _AuditsTable({required this.auditorias});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: <Widget>[
            const _TableHeaderRow(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auditorias.length,
              itemBuilder: (BuildContext context, int index) => _AuditRow(
                auditoria: auditorias[index],
                isOdd: index.isOdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = AppTypography.caption.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.slate600,
      letterSpacing: 0.4,
    );

    Widget cell(String label, int flex,
            {TextAlign align = TextAlign.left}) =>
        Expanded(
          flex: flex,
          child:
              Text(label.toUpperCase(), style: headerStyle, textAlign: align),
        );

    return Container(
      color: AppColors.slate50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          cell('ID', _kAuditColFlex[0]),
          cell('Sucursal', _kAuditColFlex[1]),
          cell('Auditor', _kAuditColFlex[2]),
          cell('Fecha', _kAuditColFlex[3]),
          cell('Score', _kAuditColFlex[4], align: TextAlign.center),
          cell('Estado', _kAuditColFlex[5]),
          cell('', _kAuditColFlex[6]),
        ],
      ),
    );
  }
}

// ─── Fila ────────────────────────────────────────────────────────────────────

class _AuditRow extends StatelessWidget {
  final AuditoriaDto auditoria;
  final bool isOdd;
  const _AuditRow({required this.auditoria, required this.isOdd});

  static Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatFecha(DateTime fecha) {
    try {
      return DateFormat.MMMd('es').format(fecha);
    } catch (_) {
      return DateFormat.MMMd().format(fecha);
    }
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Auditoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${auditoria.id}'),
            const SizedBox(height: 8),
            Text('Sucursal: ${auditoria.sucursalNombre}'),
            const SizedBox(height: 8),
            Text('Auditor: ${auditoria.auditorNombre}'),
            const SizedBox(height: 8),
            Text('Fecha: ${_formatFecha(auditoria.fechaProgramada)}'),
            const SizedBox(height: 8),
            Text('Puntaje: ${auditoria.puntaje?.round() ?? "—"}'),
            const SizedBox(height: 8),
            Text('Estado: ${auditoria.estado}'),
            if (auditoria.observaciones != null) ...[
              const SizedBox(height: 8),
              Text('Observaciones: ${auditoria.observaciones}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = isOdd ? AppColors.slate50 : Colors.white;
    final int? scoreInt = auditoria.puntaje?.round();
    final bool hasScore = scoreInt != null;
    final Color scoreColor = _scoreColor(scoreInt ?? 0);
    final String fechaTxt = _formatFecha(auditoria.fechaProgramada);

    return Material(
      color: bg,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.slate100, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              // ID
              Expanded(
                flex: _kAuditColFlex[0],
                child: Text(
                  auditoria.id,
                  style: AppTypography.monoData(12).copyWith(
                    color: AppColors.primary800,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Sucursal
              Expanded(
                flex: _kAuditColFlex[1],
                child: Text(
                  auditoria.sucursalNombre,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    color: AppColors.slate800,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Auditor
              Expanded(
                flex: _kAuditColFlex[2],
                child: Text(
                  auditoria.auditorNombre,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    color: AppColors.slate700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Fecha
              Expanded(
                flex: _kAuditColFlex[3],
                child: Text(
                  fechaTxt,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    color: AppColors.slate500,
                  ),
                ),
              ),
              // Score
              Expanded(
                flex: _kAuditColFlex[4],
                child: Align(
                  alignment: Alignment.center,
                  child: hasScore
                      ? Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scoreColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$scoreInt',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        )
                      : Text(
                          '—',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 13,
                            color: AppColors.slate400,
                          ),
                        ),
                ),
              ),
              // Estado
              Expanded(
                flex: _kAuditColFlex[5],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AuditStatusBadge(estado: auditoria.estado),
                ),
              ),
              // Más opciones
              Expanded(
                flex: _kAuditColFlex[6],
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.slate400,
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

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.slate400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin auditorías para este filtro',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.slate500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
