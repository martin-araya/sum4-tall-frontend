import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/audit_status_badge.dart';
import '../../../audits/data/models/auditoria_dto.dart';
import '../../../branches/data/datasources/sucursales_remote_datasource.dart';
import '../../../branches/data/models/sucursal_dto.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';

/// Dashboard principal de AuditChain.
///
/// Carga en paralelo:
///   - Stats de auditorías (totales, estados, puntaje promedio)
///   - Auditorías recientes (page 1, size 8)
///   - Sucursales con puntaje más bajo (para "en alerta")
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardRemoteDatasource _dashDs = DashboardRemoteDatasource();
  final SucursalesRemoteDatasource _sucursalesDs = SucursalesRemoteDatasource();

  Map<String, dynamic>? _stats;
  List<AuditoriaDto> _recentAuditorias = <AuditoriaDto>[];
  List<SucursalDto> _topSucursales = <SucursalDto>[];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Start all three requests in parallel before awaiting any of them.
      final statsF = _dashDs.getStats();
      final recentF = _dashDs.getRecentAuditorias(size: 8);
      final sucPageF = _sucursalesDs.getAll(size: 50);

      final Map<String, dynamic> stats = await statsF;
      final List<AuditoriaDto> recent = await recentF;
      final sucPage = await sucPageF;

      if (!mounted) return;

      final List<SucursalDto> sorted =
          List<SucursalDto>.from(sucPage.items)
            ..sort((SucursalDto a, SucursalDto b) =>
                a.puntajePromedio.compareTo(b.puntajePromedio));
      final List<SucursalDto> top3 = sorted.take(3).toList();

      setState(() {
        _stats = stats;
        _recentAuditorias = recent;
        _topSucursales = top3;
        _isLoading = false;
      });
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
              onPressed: _loadAll,
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

    final stats = _stats!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        return RefreshIndicator(
          onRefresh: _loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _DashboardHeader(isMobile: isMobile),
                const SizedBox(height: AppSpacing.xl),
                _KpiRow(stats: stats, isMobile: isMobile),
                const SizedBox(height: AppSpacing.lg),
                _ChartsRow(stats: stats, isMobile: isMobile),
                const SizedBox(height: AppSpacing.lg),
                _BottomRow(
                  sucursales: _topSucursales,
                  auditorias: _recentAuditorias,
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final bool isMobile;
  const _DashboardHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    String fechaHoy;
    try {
      fechaHoy = DateFormat.MMMMEEEEd('es').format(DateTime.now());
    } catch (_) {
      fechaHoy = DateFormat.MMMMEEEEd().format(DateTime.now());
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bienvenido', style: AppTypography.displayMd),
              const SizedBox(height: 4),
              Text(
                _capitalize(fechaHoy),
                style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
              ),
            ],
          ),
        ),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: () => context.go('/audits/wizard'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva auditoría'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary800,
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

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => context.go('/audits/wizard'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva auditoría'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary800,
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

    return content;
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FILA KPI
// ─────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isMobile;
  const _KpiRow({required this.stats, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final int total = (stats['total'] as num?)?.toInt() ?? 0;
    final int completadas = (stats['completadas'] as num?)?.toInt() ?? 0;
    final int pendientes = (stats['pendientes'] as num?)?.toInt() ?? 0;
    final int conObs = (stats['con_observaciones'] as num?)?.toInt() ?? 0;
    final double puntajePromedio =
        (stats['puntaje_promedio'] as num?)?.toDouble() ?? 0.0;

    final String scoreStr =
        puntajePromedio.toStringAsFixed(1).replaceAll('.', ',');
    final String totalStr =
        NumberFormat.decimalPattern('es').format(total);

    final List<_KpiItem> items = <_KpiItem>[
      _KpiItem(label: 'Total auditorías', value: totalStr),
      _KpiItem(label: 'Completadas', value: '$completadas'),
      _KpiItem(label: 'Pendientes', value: '$pendientes'),
      _KpiItem(label: 'Con observaciones', value: '$conObs'),
      _KpiItem(label: 'Score promedio', value: scoreStr),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((item) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2, // 2 columns
            child: KpiCard(label: item.label, value: item.value),
          );
        }).toList(),
      );
    }

    return Row(
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          Expanded(
            child: KpiCard(
              label: items[i].label,
              value: items[i].value,
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  const _KpiItem({required this.label, required this.value});
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FILA GRÁFICOS
// ─────────────────────────────────────────────────────────────────────────────

class _ChartsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isMobile;
  const _ChartsRow({required this.stats, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _ComplianceByRegionCard(),
          const SizedBox(height: 16),
          _StatusDistributionCard(stats: stats),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(flex: 3, child: _ComplianceByRegionCard()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _StatusDistributionCard(stats: stats)),
        ],
      ),
    );
  }
}

// ─── Compliance por región (datos estáticos — no hay endpoint por región) ────

class _ComplianceByRegionCard extends StatelessWidget {
  const _ComplianceByRegionCard();

  static const List<Map<String, Object>> _complianceData =
      <Map<String, Object>>[
    <String, Object>{
      'region': 'Norte',
      'q1': 82.0,
      'q2': 85.0,
      'q3': 88.0,
      'q4': 90.0,
    },
    <String, Object>{
      'region': 'Centro',
      'q1': 75.0,
      'q2': 78.0,
      'q3': 80.0,
      'q4': 83.0,
    },
    <String, Object>{
      'region': 'Sur',
      'q1': 88.0,
      'q2': 87.0,
      'q3': 91.0,
      'q4': 93.0,
    },
    <String, Object>{
      'region': 'Este',
      'q1': 70.0,
      'q2': 74.0,
      'q3': 76.0,
      'q4': 79.0,
    },
  ];

  static const List<Color> _quarterColors = <Color>[
    AppColors.primary600,
    AppColors.primary500,
    AppColors.accent600,
    AppColors.accent500,
  ];
  static const List<String> _quarterLabels = <String>['Q1', 'Q2', 'Q3', 'Q4'];

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Compliance por región',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List<Widget>.generate(_quarterLabels.length, (int i) {
              return _LegendDot(
                color: _quarterColors[i],
                label: _quarterLabels[i],
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 70,
                maxY: 100,
                groupsSpace: 28,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.slate900,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    getTooltipItem:
                        (BarChartGroupData group, int gIdx,
                            BarChartRodData rod, int rIdx) {
                      return BarTooltipItem(
                        '${_quarterLabels[rIdx]}  ${rod.toY.toStringAsFixed(0)}%',
                        AppTypography.bodySm.copyWith(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '${value.toInt()}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.slate500,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int idx = value.toInt();
                        if (idx < 0 || idx >= _complianceData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _complianceData[idx]['region'] as String,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.slate700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.slate200,
                    strokeWidth: 1,
                    dashArray: <int>[4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    List<BarChartGroupData>.generate(_complianceData.length,
                        (int gIdx) {
                  final Map<String, Object> region = _complianceData[gIdx];
                  final List<double> values = <double>[
                    (region['q1'] as num).toDouble(),
                    (region['q2'] as num).toDouble(),
                    (region['q3'] as num).toDouble(),
                    (region['q4'] as num).toDouble(),
                  ];
                  return BarChartGroupData(
                    x: gIdx,
                    barsSpace: 4,
                    barRods:
                        List<BarChartRodData>.generate(4, (int bIdx) {
                      return BarChartRodData(
                        toY: values[bIdx],
                        color: _quarterColors[bIdx],
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Distribución de estados (datos reales desde stats) ─────────────────────

class _StatusDistributionCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatusDistributionCard({required this.stats});

  static const Color _completadaColor = AppColors.success;
  static const Color _pendienteColor = AppColors.warning;
  static const Color _conObsColor = AppColors.conObs;
  static const Color _vencidaColor = AppColors.neutral;

  Color _colorFor(String estado) {
    switch (estado) {
      case 'completada':
        return _completadaColor;
      case 'pendiente':
        return _pendienteColor;
      case 'con_observaciones':
        return _conObsColor;
      case 'vencida':
        return _vencidaColor;
      default:
        return AppColors.slate400;
    }
  }

  String _labelFor(String estado) {
    switch (estado) {
      case 'completada':
        return 'Completadas';
      case 'pendiente':
        return 'Pendientes';
      case 'con_observaciones':
        return 'Con obs.';
      case 'vencida':
        return 'Vencidas';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> dataMap = <String, int>{
      'completada': (stats['completadas'] as num?)?.toInt() ?? 0,
      'pendiente': (stats['pendientes'] as num?)?.toInt() ?? 0,
      'con_observaciones':
          (stats['con_observaciones'] as num?)?.toInt() ?? 0,
      'vencida': (stats['vencidas'] as num?)?.toInt() ?? 0,
    };
    final List<MapEntry<String, int>> entries = dataMap.entries.toList();
    final int total =
        entries.fold<int>(0, (int a, MapEntry<String, int> b) => a + b.value);

    return _DashboardCard(
      title: 'Distribución de estados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: entries.map((MapEntry<String, int> e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        color: _colorFor(e.key),
                        radius: 36,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      NumberFormat.decimalPattern('es').format(total),
                      style: AppTypography.displayLg.copyWith(
                        color: AppColors.slate900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.slate500,
                        letterSpacing: 0.6,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: entries.map((MapEntry<String, int> e) {
              final double pct =
                  total == 0 ? 0.0 : (e.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colorFor(e.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _labelFor(e.key),
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.slate700),
                      ),
                    ),
                    Text(
                      '${NumberFormat.decimalPattern('es').format(e.value)}  ·  ${pct.toStringAsFixed(1)}%',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. FILA INFERIOR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomRow extends StatelessWidget {
  final List<SucursalDto> sucursales;
  final List<AuditoriaDto> auditorias;
  final bool isMobile;
  const _BottomRow({
    required this.sucursales,
    required this.auditorias,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SucursalesAlertaCard(sucursales: sucursales),
          const SizedBox(height: 16),
          _AuditoriasRecientesCard(auditorias: auditorias),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: _SucursalesAlertaCard(sucursales: sucursales),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _AuditoriasRecientesCard(auditorias: auditorias),
          ),
        ],
      ),
    );
  }
}

// ─── Sucursales en alerta ─────────────────────────────────────────────────────

class _SucursalesAlertaCard extends StatelessWidget {
  final List<SucursalDto> sucursales;
  const _SucursalesAlertaCard({required this.sucursales});

  Color _colorScore(double p) {
    if (p >= 80) return AppColors.success;
    if (p >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    if (sucursales.isEmpty) {
      return _DashboardCard(
        title: 'Sucursales en alerta',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              'Sin datos',
              style:
                  AppTypography.bodySm.copyWith(color: AppColors.slate400),
            ),
          ),
        ),
      );
    }

    return _DashboardCard(
      title: 'Sucursales en alerta',
      child: Column(
        children: <Widget>[
          for (int i = 0; i < sucursales.length; i++) ...<Widget>[
            _SucursalAlertRow(
              sucursal: sucursales[i],
              color: _colorScore(sucursales[i].puntajePromedio),
            ),
            if (i < sucursales.length - 1)
              const Divider(height: 1, color: AppColors.slate100),
          ],
        ],
      ),
    );
  }
}

class _SucursalAlertRow extends StatelessWidget {
  final SucursalDto sucursal;
  final Color color;
  const _SucursalAlertRow({required this.sucursal, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  sucursal.nombre,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sucursal.region,
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.slate500),
                ),
              ],
            ),
          ),
          Text(
            sucursal.puntajePromedio.toStringAsFixed(0),
            style: AppTypography.headingMd.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Auditorías recientes ─────────────────────────────────────────────────────

class _AuditoriasRecientesCard extends StatelessWidget {
  final List<AuditoriaDto> auditorias;
  const _AuditoriasRecientesCard({required this.auditorias});

  Color _colorScore(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 65) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Auditorías recientes',
      padding: EdgeInsets.zero,
      headerPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.slate50,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: const Row(
              children: <Widget>[
                _ColHeader(text: 'ID', flex: 2),
                _ColHeader(text: 'Sucursal', flex: 3),
                _ColHeader(text: 'Auditor', flex: 3),
                _ColHeader(text: 'Fecha', flex: 2),
                _ColHeader(text: 'Score', flex: 1),
                _ColHeader(text: 'Estado', flex: 2),
              ],
            ),
          ),
          if (auditorias.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Sin auditorías recientes',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.slate400),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auditorias.length,
              itemBuilder: (BuildContext context, int index) {
                final AuditoriaDto a = auditorias[index];
                final int? scoreInt = a.puntaje?.round();
                return _AuditoriaRow(
                  auditoria: a,
                  alt: index.isOdd,
                  color: _colorScore(scoreInt ?? 0),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _ColHeader({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.slate500,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AuditoriaRow extends StatelessWidget {
  final AuditoriaDto auditoria;
  final bool alt;
  final Color color;
  const _AuditoriaRow({
    required this.auditoria,
    required this.alt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String fechaTxt;
    try {
      fechaTxt = DateFormat.MMMd('es').format(auditoria.fechaProgramada);
    } catch (_) {
      fechaTxt = DateFormat.MMMd().format(auditoria.fechaProgramada);
    }

    final int? scoreInt = auditoria.puntaje?.round();
    final bool hasScore = scoreInt != null;

    return Container(
      decoration: BoxDecoration(
        color: alt ? AppColors.slate50 : Colors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.slate100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              auditoria.id,
              style: AppTypography.monoData(11).copyWith(
                color: AppColors.primary600,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              auditoria.sucursalNombre,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              auditoria.auditorNombre,
              style:
                  AppTypography.bodySm.copyWith(color: AppColors.slate700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _capitalize(fechaTxt),
              style:
                  AppTypography.bodySm.copyWith(color: AppColors.slate700),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              hasScore ? '$scoreInt' : '—',
              style: AppTypography.bodySm.copyWith(
                color: hasScore ? color : AppColors.slate400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AuditStatusBadge(estado: auditoria.estado),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD CONTENEDOR
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? headerPadding;

  const _DashboardCard({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.headerPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: headerPadding ??
                const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Text(
              title,
              style: AppTypography.headingMd.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.slate700),
        ),
      ],
    );
  }
}
