import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class AuditoresScreen extends StatefulWidget {
  const AuditoresScreen({super.key});
  @override
  State<AuditoresScreen> createState() => _AuditoresScreenState();
}

class _AuditoresScreenState extends State<AuditoresScreen> {
  List<Auditor> _auditores = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAuditores();
      setState(() { _auditores = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _abrirFormulario([Auditor? a]) {
    showDialog(context: context, builder: (_) => AuditorForm(auditor: a, onSaved: _cargar));
  }

  Future<void> _eliminar(String id) async {
    final ok = await confirmar(context, '¿Eliminar este auditor?');
    if (!ok) return;
    try {
      await ApiService.deleteAuditor(id);
      showSnack(context, 'Auditor eliminado');
      _cargar();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activos = _auditores.where((a) => a.estado == 'activo').length;
    final regiones = _auditores.map((a) => a.region).where((r) => r != null).toSet().length;

    return PageLayout(
      title: 'Auditores',
      subtitle: 'Equipo de terreno autorizado',
      onNew: () => _abrirFormulario(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsRow(stats: [
            StatCard(label: 'Total', value: '${_auditores.length}', sub: 'auditores en sistema'),
            StatCard(label: 'Activos', value: '$activos', sub: 'con acceso habilitado', valueColor: const Color(0xFF10B981)),
            StatCard(label: 'Regiones', value: '$regiones', sub: 'zonas cubiertas', valueColor: const Color(0xFF06B6D4)),
          ]),
          const SizedBox(height: 20),
          TableCard(
            count: _auditores.length,
            loading: _loading,
            headers: const ['Nombre', 'Email', 'Región', 'Estado', 'Acciones'],
            rows: _auditores.map((a) => [a.nombre, a.email, a.region ?? '—', a.estado, a.id]).toList(),
            onEdit: (i) => _abrirFormulario(_auditores[i]),
            onDelete: (i) => _eliminar(_auditores[i].id),
            estadoCol: 3,
          ),
        ],
      ),
    );
  }
}

class AuditorForm extends StatefulWidget {
  final Auditor? auditor;
  final VoidCallback onSaved;
  const AuditorForm({super.key, this.auditor, required this.onSaved});
  @override
  State<AuditorForm> createState() => _AuditorFormState();
}

class _AuditorFormState extends State<AuditorForm> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  String? _region;
  String _estado = 'activo';
  bool _saving = false;

  final _regiones = ['Región Metropolitana','Región de Valparaíso','Región del Biobío','Región de La Araucanía'];

  @override
  void initState() {
    super.initState();
    if (widget.auditor != null) {
      _nombre.text = widget.auditor!.nombre;
      _email.text = widget.auditor!.email;
      _region = widget.auditor!.region;
      _estado = widget.auditor!.estado;
    }
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    try {
      final data = {'nombre': _nombre.text, 'email': _email.text, 'region': _region, 'estado': _estado};
      if (widget.auditor != null) {
        await ApiService.updateAuditor(widget.auditor!.id, data);
      } else {
        await ApiService.createAuditor(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) showSnack(context, widget.auditor != null ? 'Auditor actualizado' : 'Auditor creado');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
    title: widget.auditor != null ? 'Editar Auditor' : 'Nuevo Auditor',
    saving: _saving,
    onSave: _guardar,
    fields: [
      FormField2(label: 'Nombre *', controller: _nombre),
      FormField2(label: 'Email *', controller: _email),
      DropdownField(label: 'Región', value: _region ?? _regiones[0], items: _regiones, onChanged: (v) => setState(() => _region = v)),
      DropdownField(label: 'Estado', value: _estado, items: const ['activo', 'inactivo'], onChanged: (v) => setState(() => _estado = v!)),
    ],
  );
}
