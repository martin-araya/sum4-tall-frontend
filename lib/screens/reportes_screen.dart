import 'package:flutter/material.dart';
import '../utils/export_csv.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<Auditoria> _auditorias = [];
  List<Sucursal> _sucursales = [];
  List<Auditor> _auditores = [];
  bool _loading = true;
  String _filtroRegion = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
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
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  // ── Datos filtrados ────────────────────────────────────────────────────────

  List<Auditoria> get _auditoriasRegion {
    if (_filtroRegion == 'Todas') return _auditorias;
    final ids = _sucursales
        .where((s) => s.region == _filtroRegion)
        .map((s) => s.id)
        .toSet();
    return _auditorias.where((a) => ids.contains(a.sucursalId)).toList();
  }

  List<String> get _regiones {
    final set = <String>{'Todas'};
    for (final s in _sucursales) {
      set.add(s.region);
    }
    return set.toList();
  }

  // ── Métricas ───────────────────────────────────────────────────────────────

  double get _compliancePromedio {
    final con = _auditoriasRegion.where((a) => a.puntaje > 0).toList();
    if (con.isEmpty) return 0;
    return con.map((a) => a.puntaje.toDouble()).reduce((a, b) => a + b) / con.length;
  }

  int get _hallazgosCriticos =>
      _auditoriasRegion.where((a) => a.estado == 'con_observaciones').length;

  int get _auditoriasCompletadas =>
      _auditoriasRegion.where((a) => a.estado == 'completada').length;

  int get _sucursalesEnRiesgo {
    if (_filtroRegion == 'Todas') {
      return _sucursales.where((s) => s.puntajePromedio > 0 && s.puntajePromedio < 60).length;
    }
    return _sucursales
        .where((s) => s.region == _filtroRegion && s.puntajePromedio > 0 && s.puntajePromedio < 60)
        .length;
  }

  // ── Compliance por región ─────────────────────────────────────────────────

  List<_RegionRow> get _regionRows {
    final Map<String, List<double>> map = {};
    final Map<String, int> conteo = {};
    for (final a in _auditorias) {
      if (a.puntaje <= 0) continue;
      try {
        final s = _sucursales.firstWhere((s) => s.id == a.sucursalId);
        map.putIfAbsent(s.region, () => []).add(a.puntaje.toDouble());
        conteo[s.region] = (conteo[s.region] ?? 0) + 1;
      } catch (_) {}
    }
    return map.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return _RegionRow(region: e.key, promedio: avg, total: conteo[e.key] ?? 0);
    }).toList()
      ..sort((a, b) => b.promedio.compareTo(a.promedio));
  }

  // ── Sucursales críticas ────────────────────────────────────────────────────

  List<Sucursal> get _sucursalesCriticas {
    final lista = _sucursales
        .where((s) => s.puntajePromedio > 0)
        .toList()
      ..sort((a, b) => a.puntajePromedio.compareTo(b.puntajePromedio));
    return lista.take(5).toList();
  }

  String _nombreAuditor(String id) => _auditores
      .firstWhere((a) => a.id == id,
          orElse: () => Auditor(id: '', nombre: '—', email: '', estado: ''))
      .nombre;

  // ── Export CSV ─────────────────────────────────────────────────────────────

  void _exportarCSV() {
    const header = 'ID,Sucursal,Auditor,Fecha,Puntaje,Estado,Notas';
    final rows = _auditoriasRegion.map((a) {
      final suc = _sucursales.firstWhere((s) => s.id == a.sucursalId,
          orElse: () => Sucursal(id: '', nombre: a.sucursalId, region: '', estado: '', puntajePromedio: 0));
      return [
        a.id,
        '"${suc.nombre}"',
        '"${_nombreAuditor(a.auditorId)}"',
        a.fecha,
        '${a.puntaje}',
        a.estado,
        '"${(a.notas ?? '').replaceAll('"', "'")}"',
      ].join(',');
    });
    final csv = [header, ...rows].join('\n');
    exportarCSV(csv, 'auditchain_reporte.csv');
    showSnack(context, 'Reporte exportado como CSV');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildKpiGrid(),
                      const SizedBox(height: 28),
                      _buildChartsRow(),
                      const SizedBox(height: 28),
                      _buildCriticasTable(),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics & Compliance',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A2540),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Métricas de rendimiento y análisis de riesgo regional',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildFiltroRegion(),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _exportarCSV,
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Exportar CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A2540),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _cargar,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar',
          color: const Color(0xFF64748B),
        ),
      ],
    );
  }

  Widget _buildFiltroRegion() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filtroRegion,
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0A2540)),
          items: _regiones
              .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _filtroRegion = v!),
        ),
      ),
    );
  }

  // ── KPI Grid ───────────────────────────────────────────────────────────────

  Widget _buildKpiGrid() {
    return Row(
      children: [
        _kpiCard(
          label: 'Compliance Global',
          value: '${_compliancePromedio.toStringAsFixed(1)}%',
          sub: 'promedio de puntajes',
          iconBg: const Color(0xFFD1FAE5),
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF065F46),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Hallazgos Críticos',
          value: '$_hallazgosCriticos',
          sub: 'con observaciones',
          iconBg: const Color(0xFFFFE4E6),
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFEF4444),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Auditorías Completadas',
          value: '$_auditoriasCompletadas',
          sub: 'de ${_auditoriasRegion.length} en período',
          iconBg: const Color(0xFFE0F2FE),
          icon: Icons.assignment_turned_in_rounded,
          iconColor: const Color(0xFF0EA5E9),
        ),
        const SizedBox(width: 16),
        _kpiCard(
          label: 'Sucursales en Riesgo',
          value: '$_sucursalesEnRiesgo',
          sub: 'score < 60%',
          iconBg: const Color(0xFFFEF3C7),
          icon: Icons.store_rounded,
          iconColor: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required String sub,
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
  }) {
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
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A2540),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compliance por Región ─────────────────────────────────────────────────

  Widget _buildChartsRow() {
    final rows = _regionRows;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, size: 18, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Text(
                'Compliance por Región',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A2540),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (rows.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sin datos de auditorías con puntaje',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ...rows.map((r) => _regionRow(r)),
        ],
      ),
    );
  }

  Widget _regionRow(_RegionRow r) {
    Color barColor;
    String statusLabel;
    if (r.promedio >= 80) {
      barColor = const Color(0xFF10B981);
      statusLabel = 'Compliant';
    } else if (r.promedio >= 60) {
      barColor = const Color(0xFFF59E0B);
      statusLabel = 'Warning';
    } else {
      barColor = const Color(0xFFEF4444);
      statusLabel = 'Critical';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              r.region,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0A2540),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: r.promedio / 100,
                backgroundColor: const Color(0xFFE2E8F0),
                color: barColor,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 52,
            child: Text(
              '${r.promedio.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: barColor.withAlpha(26),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${r.total} auditorías',
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ── Sucursales críticas ────────────────────────────────────────────────────

  Widget _buildCriticasTable() {
    final criticas = _sucursalesCriticas;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                'Sucursales con Menor Compliance',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A2540),
                ),
              ),
              const Spacer(),
              Text(
                'Top 5 más críticas',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (criticas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sin datos de sucursales con puntaje',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 60,
                    columns: ['Sucursal', 'Región', 'Compliance', 'Estado', 'Última auditoría']
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
                    rows: criticas.map((s) {
                      final score = s.puntajePromedio;
                      final Color scoreColor = score >= 80
                          ? const Color(0xFF10B981)
                          : score >= 60
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFEF4444);
                      final String statusLabel = score >= 80
                          ? 'Compliant'
                          : score >= 60
                              ? 'Warning'
                              : 'Critical';

                      final ultimaAud = _auditorias
                          .where((a) => a.sucursalId == s.id)
                          .toList()
                        ..sort((a, b) => b.fecha.compareTo(a.fecha));
                      final ultimaFecha = ultimaAud.isEmpty
                          ? '—'
                          : formatFecha(ultimaAud.first.fecha);

                      return DataRow(cells: [
                        DataCell(Text(
                          s.nombre,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A2540)),
                        )),
                        DataCell(Text(
                          s.region,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF64748B)),
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: score / 100,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  color: scoreColor,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${score.toStringAsFixed(0)}%',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: scoreColor),
                            ),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: scoreColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: scoreColor),
                          ),
                        )),
                        DataCell(Text(
                          ultimaFecha,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFF64748B)),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _RegionRow {
  final String region;
  final double promedio;
  final int total;
  const _RegionRow({required this.region, required this.promedio, required this.total});
}
