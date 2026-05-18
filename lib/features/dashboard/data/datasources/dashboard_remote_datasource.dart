import 'package:auditchain/features/audits/data/datasources/auditorias_remote_datasource.dart';
import 'package:auditchain/features/audits/data/models/auditoria_dto.dart';

/// Aggregates the data needed by the dashboard from multiple endpoints.
///
/// Delegates to [AuditoriasRemoteDatasource] so there is a single HTTP layer.
class DashboardRemoteDatasource {
  DashboardRemoteDatasource()
      : _auditoriasDs = AuditoriasRemoteDatasource();

  final AuditoriasRemoteDatasource _auditoriasDs;

  /// Audit aggregate stats: total, completadas, pendientes,
  /// con_observaciones, vencidas, puntaje_promedio.
  Future<Map<String, dynamic>> getStats() => _auditoriasDs.getStats();

  /// The [size] most recent audits (page 1).
  Future<List<AuditoriaDto>> getRecentAuditorias({int size = 5}) async {
    final page = await _auditoriasDs.getAll(page: 1, size: size);
    return page.items;
  }
}
