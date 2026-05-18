/// DTO for the AuditorOut schema returned by the backend.
///
/// The backend uses snake_case keys and `activo: bool`.
/// The [estado] getter preserves the legacy String contract ('activo'/'inactivo')
/// so existing badge widgets compile without changes.
class AuditorDto {
  const AuditorDto({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.email,
    required this.region,
    required this.activo,
    required this.creadoEn,
  });

  final String id;
  final String usuarioId;
  final String nombre;
  final String email;
  final String? region;
  final bool activo;
  final DateTime creadoEn;

  /// Backward-compat getter used by widgets that check `estado`.
  String get estado => activo ? 'activo' : 'inactivo';

  factory AuditorDto.fromJson(Map<String, dynamic> json) => AuditorDto(
        id: json['id'] as String,
        usuarioId: json['usuario_id'] as String,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        region: json['region'] as String?,
        activo: json['activo'] as bool,
        creadoEn: DateTime.parse(json['creado_en'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'usuario_id': usuarioId,
        'nombre': nombre,
        'email': email,
        'region': region,
        'activo': activo,
        'creado_en': creadoEn.toIso8601String(),
      };
}
