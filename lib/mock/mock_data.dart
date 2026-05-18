// =============================================================================
// AuditChain - Mock Data para MVP (sin backend real)
// =============================================================================
// Este archivo contiene los modelos de dominio simplificados y un dataset
// estatico utilizado por la capa de presentacion durante el desarrollo del
// MVP. Los datos reflejan un escenario realista de auditoria de franquicias
// en Chile, distribuido entre las regiones Metropolitana, Valparaiso, Biobio
// y La Araucania.
// =============================================================================

// -----------------------------------------------------------------------------
// MODELOS
// -----------------------------------------------------------------------------

/// Representa una sucursal/franquicia auditable.
class Sucursal {
  final String id;
  final String nombre;
  final String region;
  final int puntaje;
  final String estado; // 'activa' | 'inactiva'
  final DateTime ultimaAuditoria;
  final String auditorAsignado;

  const Sucursal({
    required this.id,
    required this.nombre,
    required this.region,
    required this.puntaje,
    required this.estado,
    required this.ultimaAuditoria,
    required this.auditorAsignado,
  });
}

/// Representa un auditor de la red.
class Auditor {
  final String id;
  final String nombre;
  final String email;
  final String region;
  final String estado; // 'activo' | 'inactivo'
  final int totalAuditorias;

  const Auditor({
    required this.id,
    required this.nombre,
    required this.email,
    required this.region,
    required this.estado,
    required this.totalAuditorias,
  });
}

/// Representa una auditoria realizada (o programada) sobre una sucursal.
///
/// Estados validos:
/// - 'completada'
/// - 'pendiente'
/// - 'con_observaciones'
/// - 'vencida'
class Auditoria {
  final String id;
  final String sucursalId;
  final String sucursalNombre;
  final String auditorNombre;
  final DateTime fecha;
  final int puntaje;
  final String estado;

  const Auditoria({
    required this.id,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.auditorNombre,
    required this.fecha,
    required this.puntaje,
    required this.estado,
  });
}

/// Indicadores agregados que se muestran en el dashboard principal.
class KpiData {
  final int totalAuditorias;
  final double cumplimiento;
  final int pendientes;
  final int auditoresActivos;
  final double scorePromedio;

  const KpiData({
    required this.totalAuditorias,
    required this.cumplimiento,
    required this.pendientes,
    required this.auditoresActivos,
    required this.scorePromedio,
  });
}

// -----------------------------------------------------------------------------
// DATA STORE
// -----------------------------------------------------------------------------

/// Punto de acceso unico a los datos mock del MVP.
///
/// Las fechas se calculan a partir de [_today] (= hoy) para que las
/// "ultimas auditorias" siempre se vean recientes al ejecutar la app.
class MockData {
  MockData._();

  // Fecha base (hoy). Se centraliza para mantener consistencia entre
  // sucursales y auditorias.
  static final DateTime _today = DateTime.now();

  // Helper interno: hoy menos N dias.
  static DateTime _daysAgo(int days) =>
      DateTime(_today.year, _today.month, _today.day).subtract(Duration(days: days));

  // ---------------------------------------------------------------------------
  // SUCURSALES (8 - distribuidas en 4 regiones, 2 inactivas)
  // ---------------------------------------------------------------------------
  static final List<Sucursal> _sucursales = <Sucursal>[
    Sucursal(
      id: 'SUC-001',
      nombre: 'Sucursal Mall Plaza Vespucio',
      region: 'Metropolitana',
      puntaje: 94,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(6),
      auditorAsignado: 'Valentina Lagos',
    ),
    Sucursal(
      id: 'SUC-002',
      nombre: 'Sucursal Costanera Center',
      region: 'Metropolitana',
      puntaje: 97,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(12),
      auditorAsignado: 'Matias Fuentes',
    ),
    Sucursal(
      id: 'SUC-003',
      nombre: 'Sucursal Mall Plaza Oeste',
      region: 'Metropolitana',
      puntaje: 71,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(28),
      auditorAsignado: 'Camila Bravo',
    ),
    Sucursal(
      id: 'SUC-004',
      nombre: 'Sucursal Vina Mall Marina Arauco',
      region: 'Valparaiso',
      puntaje: 88,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(9),
      auditorAsignado: 'Javiera Soto',
    ),
    Sucursal(
      id: 'SUC-005',
      nombre: 'Sucursal Mall Paseo Valparaiso',
      region: 'Valparaiso',
      puntaje: 62,
      estado: 'inactiva',
      ultimaAuditoria: _daysAgo(74),
      auditorAsignado: 'Javiera Soto',
    ),
    Sucursal(
      id: 'SUC-006',
      nombre: 'Sucursal Mall Plaza El Trebol',
      region: 'Biobio',
      puntaje: 83,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(18),
      auditorAsignado: 'Diego Carcamo',
    ),
    Sucursal(
      id: 'SUC-007',
      nombre: 'Sucursal Mall Mirador Bio Bio',
      region: 'Biobio',
      puntaje: 76,
      estado: 'activa',
      ultimaAuditoria: _daysAgo(35),
      auditorAsignado: 'Diego Carcamo',
    ),
    Sucursal(
      id: 'SUC-008',
      nombre: 'Sucursal Portal Temuco',
      region: 'La Araucania',
      puntaje: 68,
      estado: 'inactiva',
      ultimaAuditoria: _daysAgo(81),
      auditorAsignado: 'Renata Millan',
    ),
  ];

  // ---------------------------------------------------------------------------
  // AUDITORES (6 - nombres chilenos)
  // ---------------------------------------------------------------------------
  static final List<Auditor> _auditores = <Auditor>[
    Auditor(
      id: 'AUD-001',
      nombre: 'Valentina Lagos',
      email: 'valentina.lagos@auditchain.cl',
      region: 'Metropolitana',
      estado: 'activo',
      totalAuditorias: 142,
    ),
    Auditor(
      id: 'AUD-002',
      nombre: 'Matias Fuentes',
      email: 'matias.fuentes@auditchain.cl',
      region: 'Metropolitana',
      estado: 'activo',
      totalAuditorias: 118,
    ),
    Auditor(
      id: 'AUD-003',
      nombre: 'Camila Bravo',
      email: 'camila.bravo@auditchain.cl',
      region: 'Metropolitana',
      estado: 'activo',
      totalAuditorias: 96,
    ),
    Auditor(
      id: 'AUD-004',
      nombre: 'Javiera Soto',
      email: 'javiera.soto@auditchain.cl',
      region: 'Valparaiso',
      estado: 'activo',
      totalAuditorias: 87,
    ),
    Auditor(
      id: 'AUD-005',
      nombre: 'Diego Carcamo',
      email: 'diego.carcamo@auditchain.cl',
      region: 'Biobio',
      estado: 'activo',
      totalAuditorias: 73,
    ),
    Auditor(
      id: 'AUD-006',
      nombre: 'Renata Millan',
      email: 'renata.millan@auditchain.cl',
      region: 'La Araucania',
      estado: 'inactivo',
      totalAuditorias: 51,
    ),
  ];

  // ---------------------------------------------------------------------------
  // AUDITORIAS (20 - distribuidas en los 4 estados, 0-90 dias)
  //
  // Distribucion intencional:
  //   completada         -> 9
  //   pendiente          -> 5
  //   con_observaciones  -> 4
  //   vencida            -> 2
  // ---------------------------------------------------------------------------
  static final List<Auditoria> _auditorias = <Auditoria>[
    // --- completadas (9) ---
    Auditoria(
      id: 'AUDIT-0001',
      sucursalId: 'SUC-001',
      sucursalNombre: 'Sucursal Mall Plaza Vespucio',
      auditorNombre: 'Valentina Lagos',
      fecha: _daysAgo(6),
      puntaje: 94,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0002',
      sucursalId: 'SUC-002',
      sucursalNombre: 'Sucursal Costanera Center',
      auditorNombre: 'Matias Fuentes',
      fecha: _daysAgo(12),
      puntaje: 97,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0003',
      sucursalId: 'SUC-004',
      sucursalNombre: 'Sucursal Vina Mall Marina Arauco',
      auditorNombre: 'Javiera Soto',
      fecha: _daysAgo(9),
      puntaje: 88,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0004',
      sucursalId: 'SUC-006',
      sucursalNombre: 'Sucursal Mall Plaza El Trebol',
      auditorNombre: 'Diego Carcamo',
      fecha: _daysAgo(18),
      puntaje: 83,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0005',
      sucursalId: 'SUC-001',
      sucursalNombre: 'Sucursal Mall Plaza Vespucio',
      auditorNombre: 'Valentina Lagos',
      fecha: _daysAgo(38),
      puntaje: 91,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0006',
      sucursalId: 'SUC-002',
      sucursalNombre: 'Sucursal Costanera Center',
      auditorNombre: 'Matias Fuentes',
      fecha: _daysAgo(45),
      puntaje: 95,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0007',
      sucursalId: 'SUC-004',
      sucursalNombre: 'Sucursal Vina Mall Marina Arauco',
      auditorNombre: 'Javiera Soto',
      fecha: _daysAgo(52),
      puntaje: 86,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0008',
      sucursalId: 'SUC-006',
      sucursalNombre: 'Sucursal Mall Plaza El Trebol',
      auditorNombre: 'Diego Carcamo',
      fecha: _daysAgo(63),
      puntaje: 81,
      estado: 'completada',
    ),
    Auditoria(
      id: 'AUDIT-0009',
      sucursalId: 'SUC-003',
      sucursalNombre: 'Sucursal Mall Plaza Oeste',
      auditorNombre: 'Camila Bravo',
      fecha: _daysAgo(70),
      puntaje: 78,
      estado: 'completada',
    ),

    // --- pendientes (5) ---
    Auditoria(
      id: 'AUDIT-0010',
      sucursalId: 'SUC-003',
      sucursalNombre: 'Sucursal Mall Plaza Oeste',
      auditorNombre: 'Camila Bravo',
      fecha: _daysAgo(2),
      puntaje: 0,
      estado: 'pendiente',
    ),
    Auditoria(
      id: 'AUDIT-0011',
      sucursalId: 'SUC-007',
      sucursalNombre: 'Sucursal Mall Mirador Bio Bio',
      auditorNombre: 'Diego Carcamo',
      fecha: _daysAgo(4),
      puntaje: 0,
      estado: 'pendiente',
    ),
    Auditoria(
      id: 'AUDIT-0012',
      sucursalId: 'SUC-001',
      sucursalNombre: 'Sucursal Mall Plaza Vespucio',
      auditorNombre: 'Valentina Lagos',
      fecha: _daysAgo(15),
      puntaje: 0,
      estado: 'pendiente',
    ),
    Auditoria(
      id: 'AUDIT-0013',
      sucursalId: 'SUC-004',
      sucursalNombre: 'Sucursal Vina Mall Marina Arauco',
      auditorNombre: 'Javiera Soto',
      fecha: _daysAgo(25),
      puntaje: 0,
      estado: 'pendiente',
    ),
    Auditoria(
      id: 'AUDIT-0014',
      sucursalId: 'SUC-008',
      sucursalNombre: 'Sucursal Portal Temuco',
      auditorNombre: 'Renata Millan',
      fecha: _daysAgo(40),
      puntaje: 0,
      estado: 'pendiente',
    ),

    // --- con observaciones (4) ---
    Auditoria(
      id: 'AUDIT-0015',
      sucursalId: 'SUC-003',
      sucursalNombre: 'Sucursal Mall Plaza Oeste',
      auditorNombre: 'Camila Bravo',
      fecha: _daysAgo(28),
      puntaje: 71,
      estado: 'con_observaciones',
    ),
    Auditoria(
      id: 'AUDIT-0016',
      sucursalId: 'SUC-007',
      sucursalNombre: 'Sucursal Mall Mirador Bio Bio',
      auditorNombre: 'Diego Carcamo',
      fecha: _daysAgo(35),
      puntaje: 76,
      estado: 'con_observaciones',
    ),
    Auditoria(
      id: 'AUDIT-0017',
      sucursalId: 'SUC-005',
      sucursalNombre: 'Sucursal Mall Paseo Valparaiso',
      auditorNombre: 'Javiera Soto',
      fecha: _daysAgo(57),
      puntaje: 65,
      estado: 'con_observaciones',
    ),
    Auditoria(
      id: 'AUDIT-0018',
      sucursalId: 'SUC-008',
      sucursalNombre: 'Sucursal Portal Temuco',
      auditorNombre: 'Renata Millan',
      fecha: _daysAgo(81),
      puntaje: 68,
      estado: 'con_observaciones',
    ),

    // --- vencidas (2) ---
    Auditoria(
      id: 'AUDIT-0019',
      sucursalId: 'SUC-005',
      sucursalNombre: 'Sucursal Mall Paseo Valparaiso',
      auditorNombre: 'Javiera Soto',
      fecha: _daysAgo(74),
      puntaje: 62,
      estado: 'vencida',
    ),
    Auditoria(
      id: 'AUDIT-0020',
      sucursalId: 'SUC-008',
      sucursalNombre: 'Sucursal Portal Temuco',
      auditorNombre: 'Renata Millan',
      fecha: _daysAgo(88),
      puntaje: 64,
      estado: 'vencida',
    ),
  ];

  // ---------------------------------------------------------------------------
  // KPIs (dashboard principal)
  // ---------------------------------------------------------------------------
  static const KpiData _kpis = KpiData(
    totalAuditorias: 1452,
    cumplimiento: 91.2,
    pendientes: 128,
    auditoresActivos: 45,
    scorePromedio: 87.6,
  );

  // ---------------------------------------------------------------------------
  // DATOS PARA GRAFICOS
  // ---------------------------------------------------------------------------

  /// Cumplimiento por region y trimestre (BarChart agrupado).
  /// Cada Map tiene: region, q1, q2, q3, q4 (todos los q en rango 75-97).
  static const List<Map<String, dynamic>> _complianceByRegion =
      <Map<String, dynamic>>[
    <String, dynamic>{
      'region': 'Metropolitana',
      'q1': 88,
      'q2': 91,
      'q3': 94,
      'q4': 96,
    },
    <String, dynamic>{
      'region': 'Valparaiso',
      'q1': 82,
      'q2': 85,
      'q3': 87,
      'q4': 89,
    },
    <String, dynamic>{
      'region': 'Biobio',
      'q1': 79,
      'q2': 83,
      'q3': 86,
      'q4': 90,
    },
    <String, dynamic>{
      'region': 'La Araucania',
      'q1': 75,
      'q2': 78,
      'q3': 82,
      'q4': 85,
    },
  ];

  /// Distribucion del estado de las auditorias (pie/donut chart).
  static const Map<String, int> _auditStatusDistribution = <String, int>{
    'completada': 1016,
    'pendiente': 290,
    'con_observaciones': 101,
    'vencida': 45,
  };

  // ---------------------------------------------------------------------------
  // GETTERS PUBLICOS (lecturas inmutables)
  // ---------------------------------------------------------------------------

  static List<Sucursal> get sucursales => List<Sucursal>.unmodifiable(_sucursales);

  static List<Auditor> get auditores => List<Auditor>.unmodifiable(_auditores);

  static List<Auditoria> get auditorias =>
      List<Auditoria>.unmodifiable(_auditorias);

  static KpiData get kpis => _kpis;

  static List<Map<String, dynamic>> get complianceByRegion =>
      List<Map<String, dynamic>>.unmodifiable(_complianceByRegion);

  static Map<String, int> get auditStatusDistribution =>
      Map<String, int>.unmodifiable(_auditStatusDistribution);

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Devuelve la sucursal con el id indicado o `null` si no existe.
  static Sucursal? sucursalById(String id) {
    for (final Sucursal s in _sucursales) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Devuelve todas las auditorias asociadas a una sucursal, ordenadas por
  /// fecha descendente (mas recientes primero).
  static List<Auditoria> auditoriasBySucursal(String sucursalId) {
    final List<Auditoria> result = _auditorias
        .where((Auditoria a) => a.sucursalId == sucursalId)
        .toList();
    result.sort((Auditoria a, Auditoria b) => b.fecha.compareTo(a.fecha));
    return result;
  }
}
