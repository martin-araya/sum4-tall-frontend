import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});
  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  List<Sucursal> _sucursales = [];
  List<Auditoria> _auditorias = [];
  List<Auditor> _auditores = [];
  bool _loading = true;

  // Filters
  String _busqueda = '';
  String _filtroRegion = 'Todas';
  String _filtroEstado = 'Todos';

  // Pagination
  int _pagina = 0;
  static const _porPagina = 8;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getSucursales(),
        ApiService.getAuditorias(),
        ApiService.getAuditores(),
      ]);
      setState(() {
        _sucursales = results[0] as List<Sucursal>;
        _auditorias = results[1] as List<Auditoria>;
        _auditores = results[2] as List<Auditor>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _abrirFormulario([Sucursal? s]) {
    showDialog(context: context, builder: (_) => SucursalForm(sucursal: s, onSaved: _cargar));
  }

  Future<void> _eliminar(String id) async {
    final ok = await confirmar(context, '¿Eliminar esta sucursal?');
    if (!ok) return;
    try {
      await ApiService.deleteSucursal(id);
      showSnack(context, 'Sucursal eliminada');
      _cargar();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  void _limpiarFiltros() => setState(() {
        _busqueda = '';
        _filtroRegion = 'Todas';
        _filtroEstado = 'Todos';
        _pagina = 0;
      });

  List<String> get _regiones {
    final set = <String>{'Todas'};
    for (final s in _sucursales) {
      set.add(s.region);
    }
    return set.toList();
  }

  List<Sucursal> get _filtradas {
    return _sucursales.where((s) {
      final q = _busqueda.toLowerCase();
      if (q.isNotEmpty &&
          !s.nombre.toLowerCase().contains(q) &&
          !s.id.toLowerCase().contains(q)) {
        return false;
      }
      if (_filtroRegion != 'Todas' && s.region != _filtroRegion) return false;
      if (_filtroEstado != 'Todos' && s.estado != _filtroEstado) return false;
      return true;
    }).toList();
  }

  String _auditorDe(String sucursalId) {
    final auds = _auditorias
        .where((a) => a.sucursalId == sucursalId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    if (auds.isEmpty) return '—';
    try {
      return _auditores.firstWhere((a) => a.id == auds.first.auditorId).nombre;
    } catch (_) {
      return '—';
    }
  }

  String _ultimaAuditoria(String sucursalId) {
    final auds = _auditorias
        .where((a) => a.sucursalId == sucursalId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return auds.isEmpty ? '—' : auds.first.fecha;
  }

  @override
  Widget build(BuildContext context) {
    final activas = _sucursales.where((s) => s.estado == 'activo').length;
    final prom = _sucursales.isEmpty
        ? 0.0
        : _sucursales.map((s) => s.puntajePromedio).reduce((a, b) => a + b) /
            _sucursales.length;

    return PageLayout(
      title: 'Sucursales',
      subtitle: 'Gestión de locales comerciales',
      onNew: () => _abrirFormulario(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsRow(stats: [
            StatCard(
                label: 'Total',
                value: '${_sucursales.length}',
                sub: 'sucursales registradas'),
            StatCard(
                label: 'Activas',
                value: '$activas',
                sub: 'operativas',
                valueColor: const Color(0xFF10B981)),
            StatCard(
                label: 'Puntaje Prom.',
                value: '${prom.toStringAsFixed(0)}%',
                sub: 'cumplimiento promedio',
                valueColor: const Color(0xFF06B6D4)),
          ]),
          const SizedBox(height: 20),
          _buildFiltros(),
          const SizedBox(height: 12),
          _buildTabla(),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final hayFiltros =
        _busqueda.isNotEmpty || _filtroRegion != 'Todas' || _filtroEstado != 'Todos';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() {
                _busqueda = v;
                _pagina = 0;
              }),
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o ID...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFF94A3B8)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E3A8A), width: 1.5)),
              ),
            ),
          ),
          _filtroDropdown(
            width: 190,
            label: 'Región',
            value: _filtroRegion,
            items: _regiones,
            onChanged: (v) => setState(() {
              _filtroRegion = v!;
              _pagina = 0;
            }),
          ),
          _filtroDropdown(
            width: 140,
            label: 'Estado',
            value: _filtroEstado,
            items: const ['Todos', 'activo', 'inactivo'],
            onChanged: (v) => setState(() {
              _filtroEstado = v!;
              _pagina = 0;
            }),
          ),
          if (hayFiltros)
            TextButton.icon(
              onPressed: _limpiarFiltros,
              icon: const Icon(Icons.filter_list_off_rounded, size: 16),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  Widget _filtroDropdown({
    required double width,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isDense: true,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0A2540)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        ),
        items: items
            .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTabla() {
    final all = _filtradas;
    final totalPag = (all.length / _porPagina).ceil().clamp(1, 9999);
    final inicio = _pagina * _porPagina;
    final paginadas =
        all.skip(inicio).take(_porPagina).toList();

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REGISTROS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  all.isEmpty
                      ? '0 resultados'
                      : 'Mostrando ${inicio + 1}–${(inicio + paginadas.length)} de ${all.length}',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            )
          else if (all.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No hay sucursales que coincidan con los filtros',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                columns: _header('ID', 'Nombre', 'Región', 'Auditor asignado',
                    'Última auditoría', 'Compliance', 'Estado', 'Acciones'),
                rows: paginadas.map((s) => _buildRow(s)).toList(),
              ),
            ),
          if (!_loading && all.isNotEmpty && totalPag > 1)
            _buildPaginacion(totalPag),
        ],
      ),
    );
  }

  List<DataColumn> _header(String a, String b, String c, String d, String e,
      String f, String g, String h) {
    return [a, b, c, d, e, f, g, h].map((label) {
      return DataColumn(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );
    }).toList();
  }

  DataRow _buildRow(Sucursal s) {
    final score = s.puntajePromedio;
    final Color scoreColor;
    final String statusLabel;
    if (score >= 80) {
      scoreColor = const Color(0xFF10B981);
      statusLabel = 'Compliant';
    } else if (score >= 60) {
      scoreColor = const Color(0xFFF59E0B);
      statusLabel = 'Warning';
    } else {
      scoreColor = const Color(0xFFEF4444);
      statusLabel = 'Critical';
    }

    final auditor = _auditorDe(s.id);
    final inicial = auditor != '—' ? auditor[0].toUpperCase() : '?';
    final shortId = 'BR-${s.id.substring(0, 4).toUpperCase()}';

    return DataRow(cells: [
      // ID
      DataCell(Text(
        shortId,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 12, color: const Color(0xFF64748B)),
      )),
      // Nombre
      DataCell(Text(
        s.nombre,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A2540)),
      )),
      // Región
      DataCell(Text(
        s.region,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
      )),
      // Auditor asignado
      DataCell(SizedBox(
        width: 180,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1E3A8A).withAlpha(26),
              child: Text(
                inicial,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A)),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                auditor,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      )),
      // Última auditoría
      DataCell(Text(
        formatFecha(_ultimaAuditoria(s.id)),
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
      )),
      // Compliance score con barra
      DataCell(SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
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
            ),
          ],
        ),
      )),
      // Status chip (Compliant / Warning / Critical)
      DataCell(_statusChip(statusLabel, scoreColor)),
      // Acciones
      DataCell(Row(children: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, size: 16),
          onPressed: () => _abrirFormulario(s),
          color: const Color(0xFF94A3B8),
          tooltip: 'Editar',
        ),
        IconButton(
          icon: const Icon(Icons.delete_rounded, size: 16),
          onPressed: () => _eliminar(s.id),
          color: const Color(0xFFEF4444),
          tooltip: 'Eliminar',
        ),
      ])),
    ]);
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildPaginacion(int totalPag) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Página ${_pagina + 1} de $totalPag',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed:
                _pagina > 0 ? () => setState(() => _pagina--) : null,
            color: const Color(0xFF64748B),
            iconSize: 20,
          ),
          ...List.generate(totalPag.clamp(0, 5), (i) {
            final isActive = i == _pagina;
            return GestureDetector(
              onTap: () => setState(() => _pagina = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _pagina < totalPag - 1
                ? () => setState(() => _pagina++)
                : null,
            color: const Color(0xFF64748B),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ─── FORMULARIO ───────────────────────────────────────────────────────────────

class SucursalForm extends StatefulWidget {
  final Sucursal? sucursal;
  final VoidCallback onSaved;
  const SucursalForm({super.key, this.sucursal, required this.onSaved});
  @override
  State<SucursalForm> createState() => _SucursalFormState();
}

class _SucursalFormState extends State<SucursalForm> {
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  String _region = 'Región Metropolitana';
  String _estado = 'activo';
  bool _saving = false;

  final _regiones = [
    'Región Metropolitana',
    'Región de Valparaíso',
    'Región del Biobío',
    'Región de La Araucanía',
    'Región de Los Lagos',
    'Región de Antofagasta',
    'Región de Coquimbo'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sucursal != null) {
      _nombre.text = widget.sucursal!.nombre;
      _direccion.text = widget.sucursal!.direccion ?? '';
      _region = widget.sucursal!.region;
      _estado = widget.sucursal!.estado;
    }
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    try {
      final data = {
        'nombre': _nombre.text,
        'region': _region,
        'direccion':
            _direccion.text.isEmpty ? null : _direccion.text,
        'estado': _estado
      };
      if (widget.sucursal != null) {
        await ApiService.updateSucursal(widget.sucursal!.id, data);
      } else {
        await ApiService.createSucursal(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) {
        showSnack(
            context,
            widget.sucursal != null
                ? 'Sucursal actualizada'
                : 'Sucursal creada');
      }
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
        title: widget.sucursal != null ? 'Editar Sucursal' : 'Nueva Sucursal',
        saving: _saving,
        onSave: _guardar,
        fields: [
          FormField2(label: 'Nombre *', controller: _nombre),
          DropdownField(
              label: 'Región *',
              value: _region,
              items: _regiones,
              onChanged: (v) => setState(() => _region = v!)),
          FormField2(label: 'Dirección', controller: _direccion),
          DropdownField(
              label: 'Estado',
              value: _estado,
              items: const ['activo', 'inactivo'],
              onChanged: (v) => setState(() => _estado = v!)),
        ],
      );
}
