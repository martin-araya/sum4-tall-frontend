import 'package:dio/dio.dart';

import 'package:auditchain/core/constants/api_constants.dart';
import 'package:auditchain/core/network/dio_client.dart';
import 'package:auditchain/core/network/paginated_response.dart';
import '../models/auditoria_dto.dart';

/// Remote datasource for the /auditorias resource.
class AuditoriasRemoteDatasource {
  AuditoriasRemoteDatasource() : _dio = DioClient.getInstance();

  final Dio _dio;

  // ── Queries ──────────────────────────────────────────────────────────────────

  Future<PaginatedResponse<AuditoriaDto>> getAll({
    int page = 1,
    int size = 50,
    String? estado,
    String? sucursalId,
  }) async {
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (estado != null) params['estado'] = estado;
      if (sucursalId != null) params['sucursal_id'] = sucursalId;

      final Response<dynamic> response = await _dio.get(
        ApiConstants.auditorias,
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        AuditoriaDto.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuditoriaDto> getById(String id) async {
    try {
      final Response<dynamic> response =
          await _dio.get('${ApiConstants.auditorias}/$id');
      return AuditoriaDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Returns aggregate stats used by the dashboard.
  /// Shape is backend-defined; callers receive a raw [Map].
  Future<Map<String, dynamic>> getStats() async {
    try {
      final Response<dynamic> response =
          await _dio.get(ApiConstants.auditoriaStats);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────────

  /// [data] must include: sucursal_id, auditor_id, fecha_programada.
  Future<AuditoriaDto> create(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.post(ApiConstants.auditorias, data: data);
      return AuditoriaDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuditoriaDto> update(String id, Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.put('${ApiConstants.auditorias}/$id', data: data);
      return AuditoriaDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────────

  Exception _handleError(DioException e) {
    final dynamic body = e.response?.data;
    final String? detail =
        body is Map ? body['detail']?.toString() : null;
    return Exception(detail ?? 'Error al conectar con el servidor');
  }
}
