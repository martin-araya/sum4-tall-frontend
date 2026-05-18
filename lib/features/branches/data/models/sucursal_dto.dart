/// DTO for the SucursalOut schema returned by the backend.
///
/// The backend uses snake_case keys and `activo: bool`.
/// The legacy UI used `estado: String` ('activo'/'inactivo'); the [estado]
/// getter preserves that contract so existing widgets compile unchanged.
class SucursalDto {
  const SucursalDto({
    required this.id,
    required this.nombre,
    required this.region,
    required this.direccion,
    required this.puntajePromedio,
    required this.activo,
    required this.creadoEn,
  });

  final String id;
  final String nombre;
  final String region;
  final String? direccion;
  final double puntajePromedio;
  final bool activo;
  final DateTime creadoEn;

  /// Backward-compat getter used by legacy widgets that check `estado`.
  String get estado => activo ? 'activo' : 'inactivo';

  factory SucursalDto.fromJson(Map<String, dynamic> json) => SucursalDto(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        region: json['region'] as String,
        direccion: json['direccion'] as String?,
        puntajePromedio: (json['puntaje_promedio'] as num).toDouble(),
        activo: json['activo'] as bool,
        creadoEn: DateTime.parse(json['creado_en'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nombre': nombre,
        'region': region,
        'direccion': direccion,
        'puntaje_promedio': puntajePromedio,
        'activo': activo,
        'creado_en': creadoEn.toIso8601String(),
      };
}
