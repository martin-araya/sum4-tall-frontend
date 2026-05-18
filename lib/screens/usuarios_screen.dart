import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});
  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Usuario> _usuarios = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getUsuarios();
      setState(() { _usuarios = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _abrirNuevo() {
    showDialog(context: context, builder: (_) => UsuarioForm(onSaved: _cargar));
  }

  void _abrirEdicion(Usuario u) {
    showDialog(context: context, builder: (_) => UsuarioEditForm(usuario: u, onSaved: _cargar));
  }

  Future<void> _eliminar(String id) async {
    final ok = await confirmar(context, '¿Eliminar este usuario?');
    if (!ok) return;
    try {
      await ApiService.deleteUsuario(id);
      showSnack(context, 'Usuario eliminado');
      _cargar();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activos = _usuarios.where((u) => u.activo).length;
    final admins = _usuarios.where((u) => u.rol == 'admin').length;

    return PageLayout(
      title: 'Usuarios',
      subtitle: 'Cuentas de acceso al sistema',
      onNew: _abrirNuevo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsRow(stats: [
            StatCard(label: 'Total', value: '${_usuarios.length}', sub: 'usuarios registrados'),
            StatCard(label: 'Activos', value: '$activos', sub: 'con acceso habilitado', valueColor: const Color(0xFF10B981)),
            StatCard(label: 'Admins', value: '$admins', sub: 'con permisos totales', valueColor: const Color(0xFF06B6D4)),
          ]),
          const SizedBox(height: 20),
          TableCard(
            count: _usuarios.length,
            loading: _loading,
            headers: const ['Nombre', 'Email', 'Rol', 'Estado', 'Acciones'],
            rows: _usuarios.map((u) => [u.nombre, u.email, u.rol, u.activo ? 'activo' : 'inactivo', u.id]).toList(),
            onEdit: (i) => _abrirEdicion(_usuarios[i]),
            onDelete: (i) => _eliminar(_usuarios[i].id),
            estadoCol: 3,
          ),
        ],
      ),
    );
  }
}

// ─── Formulario de creación ───────────────────────────────────────────────────

class UsuarioForm extends StatefulWidget {
  final VoidCallback onSaved;
  const UsuarioForm({super.key, required this.onSaved});
  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _rol = 'auditor';
  bool _saving = false;

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      showSnack(context, 'Completa nombre, email y contraseña', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.createUsuario({
        'nombre': _nombre.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'rol': _rol,
        'activo': true,
      });
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) showSnack(context, 'Usuario creado');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
    title: 'Nuevo Usuario',
    saving: _saving,
    onSave: _guardar,
    fields: [
      FormField2(label: 'Nombre *', controller: _nombre),
      FormField2(label: 'Email *', controller: _email),
      FormField2(label: 'Contraseña *', controller: _password, obscure: true),
      DropdownField(
        label: 'Rol',
        value: _rol,
        items: const ['admin', 'supervisor', 'auditor'],
        onChanged: (v) => setState(() => _rol = v!),
      ),
    ],
  );
}

// ─── Formulario de edición ────────────────────────────────────────────────────

class UsuarioEditForm extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onSaved;
  const UsuarioEditForm({super.key, required this.usuario, required this.onSaved});
  @override
  State<UsuarioEditForm> createState() => _UsuarioEditFormState();
}

class _UsuarioEditFormState extends State<UsuarioEditForm> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  String _rol = 'auditor';
  bool _activo = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombre.text = widget.usuario.nombre;
    _email.text = widget.usuario.email;
    _rol = widget.usuario.rol;
    _activo = widget.usuario.activo;
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty || _email.text.trim().isEmpty) {
      showSnack(context, 'Nombre y email son requeridos', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.updateUsuario(widget.usuario.id, {
        'nombre': _nombre.text.trim(),
        'email': _email.text.trim(),
        'rol': _rol,
        'activo': _activo,
      });
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) showSnack(context, 'Usuario actualizado');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
    title: 'Editar Usuario',
    saving: _saving,
    onSave: _guardar,
    fields: [
      FormField2(label: 'Nombre *', controller: _nombre),
      FormField2(label: 'Email *', controller: _email),
      DropdownField(
        label: 'Rol',
        value: _rol,
        items: const ['admin', 'supervisor', 'auditor'],
        onChanged: (v) => setState(() => _rol = v!),
      ),
      DropdownField(
        label: 'Estado',
        value: _activo ? 'activo' : 'inactivo',
        items: const ['activo', 'inactivo'],
        onChanged: (v) => setState(() => _activo = v == 'activo'),
      ),
    ],
  );
}
