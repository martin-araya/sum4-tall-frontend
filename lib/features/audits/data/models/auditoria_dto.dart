/// DTO for the AuditoriaOut schema returned by the backend.
///
/// Alias getters preserve the legacy field names used by existing widgets:
///   - [fecha]  → [fechaProgramada]
///   - [notas]  → [observaciones]
class AuditoriaDto {
  const AuditoriaDto({
    required this.id,
    required this.sucursalId,
    required this.auditorId,
    required this.fechaProgramada,
    required this.observaciones,
    required this.estado,
    required this.puntaje,
    required this.sucursalNombre,
    required this.auditorNombre,
    required this.creadoEn,
  });

  final String id;
  final String sucursalId;
  final String auditorId;
  final DateTime fechaProgramada;
  final String? observaciones;
  final String estado;
  final double? puntaje;
  final String sucursalNombre;
  final String auditorNombre;
  final DateTime creadoEn;

  /// Alias for [fechaProgramada] — used by legacy widgets that reference `fecha`.
  DateTime get fecha => fechaProgramada;

  /// Alias for [observaciones] — used by legacy widgets that reference `notas`.
  String? get notas => observaciones;

  factory AuditoriaDto.fromJson(Map<String, dynamic> json) => AuditoriaDto(
        id: json['id'] as String,
        sucursalId: json['sucursal_id'] as String,
        auditorId: json['auditor_id'] as String,
        fechaProgramada:
            DateTime.parse(json['fecha_programada'] as String),
        observaciones: json['observaciones'] as String?,
        estado: json['estado'] as String,
        puntaje: json['puntaje'] == null
            ? null
            : (json['puntaje'] as num).toDouble(),
        sucursalNombre: json['sucursal_nombre'] as String,
        auditorNombre: json['auditor_nombre'] as String,
        creadoEn: DateTime.parse(json['creado_en'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sucursal_id': sucursalId,
        'auditor_id': auditorId,
        'fecha_programada': fechaProgramada.toIso8601String(),
        'observaciones': observaciones,
        'estado': estado,
        'puntaje': puntaje,
        'sucursal_nombre': sucursalNombre,
        'auditor_nombre': auditorNombre,
        'creado_en': creadoEn.toIso8601String(),
      };
}
