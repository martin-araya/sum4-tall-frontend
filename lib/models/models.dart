// ─── Sucursal ─────────────────────────────────────────────────────────────────
class Sucursal {
  final String id;
  final String nombre;
  final String region;
  final String? direccion;
  final String estado;
  final double puntajePromedio;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.region,
    this.direccion,
    required this.estado,
    required this.puntajePromedio,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    String estadoVal = 'activo';
    if (json['estado'] != null) {
      estadoVal = json['estado'];
    } else if (json['activo'] != null) {
      estadoVal = (json['activo'] == true) ? 'activo' : 'inactivo';
    }
    return Sucursal(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      region: json['region'] ?? '',
      direccion: json['direccion'],
      estado: estadoVal,
      puntajePromedio: json['puntaje_promedio'] != null ? (json['puntaje_promedio'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'region': region,
        'direccion': direccion,
        'estado': estado,
        'activo': estado == 'activo',
      };
}

// ─── Auditor ──────────────────────────────────────────────────────────────────
class Auditor {
  final String id;
  final String nombre;
  final String email;
  final String? region;
  final String estado;

  Auditor({
    required this.id,
    required this.nombre,
    required this.email,
    this.region,
    required this.estado,
  });

  factory Auditor.fromJson(Map<String, dynamic> json) {
    String estadoVal = 'activo';
    if (json['estado'] != null) {
      estadoVal = json['estado'];
    } else if (json['activo'] != null) {
      estadoVal = (json['activo'] == true) ? 'activo' : 'inactivo';
    }
    return Auditor(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      region: json['region'],
      estado: estadoVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'region': region,
        'estado': estado,
        'activo': estado == 'activo',
      };
}

// ─── Auditoria ────────────────────────────────────────────────────────────────
class Auditoria {
  final String id;
  final String sucursalId;
  final String auditorId;
  final String fecha;
  final int puntaje;
  final String estado;
  final String? notas;

  Auditoria({
    required this.id,
    required this.sucursalId,
    required this.auditorId,
    required this.fecha,
    required this.puntaje,
    required this.estado,
    this.notas,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) => Auditoria(
        id: json['id'] ?? '',
        sucursalId: json['sucursal_id'] ?? '',
        auditorId: json['auditor_id'] ?? '',
        fecha: json['fecha'] ?? json['fecha_programada'] ?? '',
        puntaje: json['puntaje'] != null ? (json['puntaje'] as num).toInt() : 0,
        estado: json['estado'] ?? 'pendiente',
        notas: json['notas'] ?? json['observaciones'],
      );

  Map<String, dynamic> toJson() => {
        'sucursal_id': sucursalId,
        'auditor_id': auditorId,
        'fecha': fecha,
        'fecha_programada': fecha,
        'puntaje': puntaje,
        'estado': estado,
        'notas': notas,
        'observaciones': notas,
      };
}

// ─── Usuario ──────────────────────────────────────────────────────────────────
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? '',
        email: json['email'] ?? '',
        rol: json['rol'] ?? 'auditor',
        activo: json['activo'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'activo': activo,
      };
}
