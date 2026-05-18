import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Auditoria> _auditorias = [];
  List<Sucursal> _sucursales = [];
  List<Auditor> _auditores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getAuditorias(),
        ApiService.getSucursales(),
        ApiService.getAuditores(),
      ]);
      setState(() {
        _auditorias = results[0] as List<Auditoria>;
        _sucursales = results[1] as List<Sucursal>;
        _auditores = results[2] as List<Auditor>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'No se pudo conectar con el servidor. Verifica que el backend esté activo.';
      });
    }
  }

  // ── Métricas calculadas ────────────────────────────────────────────────────

  int get _total => _auditorias.length;

  int get _pendientes => _auditorias.where((a) => a.estado == 'pendiente').length;

  int get _completadas => _auditorias.where((a) => a.estado == 'completada').length;

  int get _conObs => _auditorias.where((a) => a.estado == 'con_observaciones').length;

  int get _auditoresActivos => _auditores.where((a) => a.estado == 'activo').length;

  double get _cumplimiento {
    final withScore = _auditorias.where((a) => a.puntaje > 0).toList();
    if (withScore.isEmpty) return 0;
    return withScore.map((a) => a.puntaje).reduce((a, b) => a + b) / withScore.length;
  }

  double get _scoreRed {
    final withScore = _sucursales.where((s) => s.puntajePromedio > 0).toList();
    if (withScore.isEmpty) return 0;
    return withScore.map((s) => s.puntajePromedio).reduce((a, b) => a + b) /
        withScore.length;
  }

  List<Sucursal> get _peoresSucursales {
    final sorted = [..._sucursales]
      ..sort((a, b) => a.puntajePromedio.compareTo(b.puntajePromedio));
    return sorted.take(3).toList();
  }

  List<Auditoria> get _recientes {
    final sorted = [..._auditorias]..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted.take(5).toList();
  }

  // Puntaje histórico almacenado por región (de modelo Sucursal)
  Map<String, double> get _scoreHistoricoPorRegion {
    final Map<String, List<double>> map = {};
    for (final s in _sucursales) {
      if (s.puntajePromedio > 0) {
        map.putIfAbsent(s.region, () => []).add(s.puntajePromedio);
      }
    }
    return map.map((region, scores) =>
        MapEntry(region, scores.reduce((a, b) => a + b) / scores.length));
  }

  // Puntaje actual calculado desde auditorías (promedio por región)
  Map<String, double> get _scoreActualPorRegion {
    final Map<String, List<double>> map = {};
    for (final a in _auditorias) {
      if (a.puntaje <= 0) continue;
      try {
        final s = _sucursales.firstWhere((s) => s.id == a.sucursalId);
        map.putIfAbsent(s.region, () => []).add(a.puntaje.toDouble());
      } catch (_) {}
    }
    return map.map((region, scores) =>
        MapEntry(region, scores.reduce((a, b) => a + b) / scores.length));
  }

  String _nombreSucursal(String id) =>
      _sucursales.firstWhere((s) => s.id == id, orElse: () => Sucursal(id: '', nombre: id.substring(0, 8), region: '', estado: '', puntajePromedio: 0)).nombre;

  String _nombreAuditor(String id) =>
      _auditores.firstWhere((a) => a.id == id, orElse: () => Auditor(id: '', nombre: id.substring(0, 8), email: '', estado: '')).nombre;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
      );
    }
    if (_error != null) return _buildError();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildKpiRow(),
                const SizedBox(height: 24),
                _buildChartsRow(),
                const SizedBox(height: 24),
                _buildRiskCard(),
                const SizedBox(height: 24),
                _buildRecentTable(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final now = DateTime.now();
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final fecha = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenida, Admin',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A2540),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumen general de auditorías · $fecha',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _cargar,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Actualizar'),
        ),
      ],
    );
  }

  // ── KPI Row ────────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    final pendientePct = _total > 0 ? '${(_pendientes / _total * 100).toStringAsFixed(0)}% del total' : 'sin auditorías';
    return Row(
      children: [
        _kpiCard(
          label: 'Total auditorías',
          value: '$_total',
          sub: '$_completadas completadas',
          icon: Icons.assignment_rounded,
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Cumplimiento',
          value: '${_cumplimiento.toStringAsFixed(1)}%',
          sub: 'promedio de puntajes',
          icon: Icons.verified_rounded,
          accent: const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Pendientes',
          value: '$_pendientes',
          sub: pendientePct,
          icon: Icons.pending_actions_rounded,
          accent: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Auditores activos',
          value: '$_auditoresActivos',
          sub: 'de ${_auditores.length} en sistema',
          icon: Icons.people_rounded,
          accent: const Color(0xFF06B6D4),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Score prom. red',
          value: '${_scoreRed.toStringAsFixed(1)}/100',
          sub: 'todas las sucursales',
          icon: Icons.bar_chart_rounded,
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    Color? accent,
  }) {
    final color = accent ?? const Color(0xFF1E3A8A);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A2540),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Charts Row ─────────────────────────────────────────────────────────────

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBarChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildDonutChart()),
      ],
    );
  }

  Widget _buildBarChart() {
    final historico = _scoreHistoricoPorRegion;
    final actual = _scoreActualPorRegion;
    final allRegions = {...historico.keys, ...actual.keys}.toList()
      ..sort((a, b) => (historico[b] ?? 0).compareTo(historico[a] ?? 0));

    return _chartCard(
      title: 'Compliance por región',
      child: allRegions.isEmpty
          ? _emptyChart('Sin datos de sucursales por región')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      groupsSpace: 12,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF0A2540),
                          getTooltipItem: (group, _, rod, rodIndex) {
                            final region = allRegions[group.x];
                            final label = rodIndex == 0 ? 'Histórico' : 'Actual';
                            return BarTooltipItem(
                              '$region\n$label: ${rod.toY.toStringAsFixed(1)}%',
                              GoogleFonts.inter(color: Colors.white, fontSize: 11),
                            );
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (_) =>
                            const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 25,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}%',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= allRegions.length) {
                                return const SizedBox.shrink();
                              }
                              final r = allRegions[i];
                              final short = r.contains('Metropolitana')
                                  ? 'R.M.'
                                  : r.contains('Valparaíso')
                                      ? 'Valp.'
                                      : r.contains('Biobío')
                                          ? 'Biobío'
                                          : r.length > 8
                                              ? '${r.substring(0, 7)}.'
                                              : r;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(short,
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B))),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: allRegions.asMap().entries.map((e) {
                        final hist = (historico[e.value] ?? 0).clamp(0.0, 100.0);
                        final act = (actual[e.value] ?? 0).clamp(0.0, 100.0);
                        return BarChartGroupData(
                          x: e.key,
                          groupVertically: false,
                          barRods: [
                            BarChartRodData(
                              toY: hist,
                              color: const Color(0xFF0A2540),
                              width: 14,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                            ),
                            BarChartRodData(
                              toY: act > 0 ? act : hist * 0.9,
                              color: const Color(0xFF06B6D4),
                              width: 14,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _barLegendDot(const Color(0xFF0A2540), 'Histórico'),
                    const SizedBox(width: 16),
                    _barLegendDot(const Color(0xFF06B6D4), 'Actual'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _barLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDonutChart() {
    final total = _total;
    final sections = [
      if (_completadas > 0)
        PieChartSectionData(
          value: _completadas.toDouble(),
          color: const Color(0xFF10B981),
          title: '${((_completadas / total) * 100).toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          radius: 52,
        ),
      if (_pendientes > 0)
        PieChartSectionData(
          value: _pendientes.toDouble(),
          color: const Color(0xFFF59E0B),
          title: '${((_pendientes / total) * 100).toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          radius: 52,
        ),
      if (_conObs > 0)
        PieChartSectionData(
          value: _conObs.toDouble(),
          color: const Color(0xFF0EA5E9),
          title: '${((_conObs / total) * 100).toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          radius: 52,
        ),
    ];

    return _chartCard(
      title: 'Distribución de estados',
      child: total == 0
          ? _emptyChart('Sin auditorías registradas')
          : Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 56,
                          sectionsSpace: 3,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0A2540),
                            ),
                          ),
                          Text(
                            'total',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _legend(),
              ],
            ),
    );
  }

  Widget _legend() {
    return Column(
      children: [
        _legendItem(const Color(0xFF10B981), 'Completadas', _completadas),
        const SizedBox(height: 6),
        _legendItem(const Color(0xFFF59E0B), 'Pendientes', _pendientes),
        const SizedBox(height: 6),
        _legendItem(const Color(0xFF0EA5E9), 'Con observaciones', _conObs),
      ],
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
        ),
        Text(
          '$count',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A2540),
          ),
        ),
      ],
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A2540),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Risk Card ──────────────────────────────────────────────────────────────

  Widget _buildRiskCard() {
    final peores = _peoresSucursales;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                'Sucursales con mayor riesgo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A2540),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (peores.isEmpty)
            Text(
              'Sin datos de sucursales',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            )
          else
            ...peores.map((s) => _riskRow(s)),
        ],
      ),
    );
  }

  Widget _riskRow(Sucursal s) {
    final score = s.puntajePromedio;
    Color scoreColor;
    if (score >= 75) {
      scoreColor = const Color(0xFF10B981);
    } else if (score >= 60) {
      scoreColor = const Color(0xFFF59E0B);
    } else {
      scoreColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store_rounded, size: 18, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A2540),
                  ),
                ),
                Text(
                  s.region,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.toStringAsFixed(1)}/100',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: scoreColor,
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Table ───────────────────────────────────────────────────────────

  Widget _buildRecentTable() {
    final recientes = _recientes;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Auditorías recientes',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A2540),
              ),
            ),
          ),
          const Divider(height: 1),
          if (recientes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No hay auditorías registradas',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 52,
                dataRowMaxHeight: 60,
                columnSpacing: 24,
                horizontalMargin: 16,
                columns: ['ID', 'Sucursal', 'Auditor', 'Fecha', 'Puntaje', 'Estado']
                    .map((h) => DataColumn(
                          label: Text(
                            h,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ))
                    .toList(),
                rows: recientes.map((a) {
                  final shortId = '#${a.id.substring(0, 8).toUpperCase()}';
                  return DataRow(cells: [
                    DataCell(Text(
                      shortId,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    )),
                    DataCell(Text(
                      _nombreSucursal(a.sucursalId),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A2540),
                      ),
                    )),
                    DataCell(Text(
                      _nombreAuditor(a.auditorId),
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                    )),
                    DataCell(Text(
                      formatFecha(a.fecha),
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                    )),
                    DataCell(_scoreChip(a.puntaje)),
                    DataCell(EstadoBadge(estado: a.estado)),
                  ]);
                }).toList(),
              ),       // closes DataTable
              ),       // closes ConstrainedBox
              ),       // closes SingleChildScrollView
            ),         // closes LayoutBuilder
        ],
      ),
    );
  }

  Widget _scoreChip(int puntaje) {
    Color color;
    if (puntaje >= 90) {
      color = const Color(0xFF10B981);
    } else if (puntaje >= 75) {
      color = const Color(0xFF06B6D4);
    } else if (puntaje >= 60) {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF94A3B8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$puntaje%',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'Sin conexión al servidor',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyChart(String msg) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Text(msg, style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
      ),
    );
  }
}
