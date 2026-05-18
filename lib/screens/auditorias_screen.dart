import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class AuditoriasScreen extends StatefulWidget {
  const AuditoriasScreen({super.key});
  @override
  State<AuditoriasScreen> createState() => _AuditoriasScreenState();
}

class _AuditoriasScreenState extends State<AuditoriasScreen> {
  List<Auditoria> _auditorias = [];
  List<Sucursal> _sucursales = [];
  List<Auditor> _auditores = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _cargar(); }

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

  void _abrirFormulario([Auditoria? a]) {
    showDialog(context: context, builder: (_) => AuditoriaForm(
      auditoria: a,
      sucursales: _sucursales,
      auditores: _auditores,
      onSaved: _cargar,
    ));
  }

  Future<void> _eliminar(String id) async {
    final ok = await confirmar(context, '¿Eliminar esta auditoría?');
    if (!ok) return;
    try {
      await ApiService.deleteAuditoria(id);
      showSnack(context, 'Auditoría eliminada');
      _cargar();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  String _nombreSucursal(String id) => _sucursales.firstWhere(
      (s) => s.id == id,
      orElse: () => Sucursal(id: '', nombre: id.length >= 8 ? id.substring(0, 8) : id, region: '', estado: '', puntajePromedio: 0)).nombre;

  String _nombreAuditor(String id) => _auditores.firstWhere(
      (a) => a.id == id,
      orElse: () => Auditor(id: '', nombre: id.length >= 8 ? id.substring(0, 8) : id, email: '', estado: '')).nombre;

  String _truncarNotas(String? notas) {
    if (notas == null || notas.isEmpty) return '—';
    return notas.length > 40 ? '${notas.substring(0, 40)}…' : notas;
  }

  @override
  Widget build(BuildContext context) {
    final completadas = _auditorias.where((a) => a.estado == 'completada').length;
    final conObs = _auditorias.where((a) => a.estado == 'con_observaciones').length;
    final conPuntaje = _auditorias.where((a) => a.puntaje > 0).toList();
    final prom = conPuntaje.isEmpty
        ? 0.0
        : conPuntaje.map((a) => a.puntaje.toDouble()).reduce((a, b) => a + b) / conPuntaje.length;

    return PageLayout(
      title: 'Auditorías',
      subtitle: 'Historial de visitas e inspecciones',
      onNew: () => _abrirFormulario(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsRow(stats: [
            StatCard(label: 'Total', value: '${_auditorias.length}', sub: 'auditorías registradas'),
            StatCard(label: 'Completadas', value: '$completadas', sub: 'sin observaciones', valueColor: const Color(0xFF10B981)),
            StatCard(label: 'Con Observ.', value: '$conObs', sub: 'requieren seguimiento'),
            StatCard(label: 'Puntaje Prom.', value: '${prom.toStringAsFixed(0)}%', sub: 'auditorías con puntaje', valueColor: const Color(0xFF06B6D4)),
          ]),
          const SizedBox(height: 20),
          TableCard(
            count: _auditorias.length,
            loading: _loading,
            headers: const ['Sucursal', 'Auditor', 'Fecha', 'Puntaje', 'Estado', 'Notas', 'Acciones'],
            rows: _auditorias.map((a) => [
              _nombreSucursal(a.sucursalId),
              _nombreAuditor(a.auditorId),
              formatFecha(a.fecha),
              '${a.puntaje}%',
              a.estado,
              _truncarNotas(a.notas),
              a.id,
            ]).toList(),
            onEdit: (i) => _abrirFormulario(_auditorias[i]),
            onDelete: (i) => _eliminar(_auditorias[i].id),
            puntajeCol: 3,
            estadoCol: 4,
          ),
        ],
      ),
    );
  }
}

class AuditoriaForm extends StatefulWidget {
  final Auditoria? auditoria;
  final List<Sucursal> sucursales;
  final List<Auditor> auditores;
  final VoidCallback onSaved;
  const AuditoriaForm({super.key, this.auditoria, required this.sucursales, required this.auditores, required this.onSaved});
  @override
  State<AuditoriaForm> createState() => _AuditoriaFormState();
}

class _AuditoriaFormState extends State<AuditoriaForm> {
  final _puntaje = TextEditingController();
  final _notas = TextEditingController();
  String? _sucursalId;
  String? _auditorId;
  String _estado = 'pendiente';
  String _fecha = DateTime.now().toIso8601String().substring(0, 10);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.auditoria != null) {
      _sucursalId = widget.auditoria!.sucursalId;
      _auditorId = widget.auditoria!.auditorId;
      _fecha = widget.auditoria!.fecha;
      _puntaje.text = widget.auditoria!.puntaje.toString();
      _estado = widget.auditoria!.estado;
      _notas.text = widget.auditoria!.notas ?? '';
    } else {
      _puntaje.text = '75';
      if (widget.sucursales.isNotEmpty) _sucursalId = widget.sucursales[0].id;
      if (widget.auditores.isNotEmpty) _auditorId = widget.auditores[0].id;
    }
  }

  Future<void> _guardar() async {
    if (_sucursalId == null || _auditorId == null) {
      showSnack(context, 'Selecciona sucursal y auditor', error: true);
      return;
    }
    final p = int.tryParse(_puntaje.text);
    if (p == null || p < 0 || p > 100) {
      showSnack(context, 'El puntaje debe ser un número entre 0 y 100', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'sucursal_id': _sucursalId,
        'auditor_id': _auditorId,
        'fecha': _fecha,
        'puntaje': p,
        'estado': _estado,
        'notas': _notas.text.isEmpty ? null : _notas.text,
      };
      if (widget.auditoria != null) {
        await ApiService.updateAuditoria(widget.auditoria!.id, data);
      } else {
        await ApiService.createAuditoria(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) showSnack(context, widget.auditoria != null ? 'Auditoría actualizada' : 'Auditoría creada');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
    title: widget.auditoria != null ? 'Editar Auditoría' : 'Nueva Auditoría',
    saving: _saving,
    onSave: _guardar,
    fields: [
      DropdownField(
        label: 'Sucursal *',
        value: _sucursalId ?? '',
        items: widget.sucursales.map((s) => s.id).toList(),
        labels: widget.sucursales.map((s) => s.nombre).toList(),
        onChanged: (v) => setState(() => _sucursalId = v),
      ),
      DropdownField(
        label: 'Auditor *',
        value: _auditorId ?? '',
        items: widget.auditores.map((a) => a.id).toList(),
        labels: widget.auditores.map((a) => a.nombre).toList(),
        onChanged: (v) => setState(() => _auditorId = v),
      ),
      DateField(
        label: 'Fecha *',
        value: _fecha,
        onChanged: (v) => setState(() => _fecha = v),
      ),
      FormField2(label: 'Puntaje (0–100) *', controller: _puntaje),
      DropdownField(
        label: 'Estado',
        value: _estado,
        items: const ['pendiente', 'completada', 'con_observaciones'],
        onChanged: (v) => setState(() => _estado = v!),
      ),
      FormField2(label: 'Notas', controller: _notas, maxLines: 3),
    ],
  );
}
