import 'package:dio/dio.dart';

import 'package:auditchain/core/constants/api_constants.dart';
import 'package:auditchain/core/network/dio_client.dart';
import 'package:auditchain/core/network/paginated_response.dart';
import '../models/auditor_dto.dart';

/// Remote datasource for the /auditores resource.
class AuditoresRemoteDatasource {
  AuditoresRemoteDatasource() : _dio = DioClient.getInstance();

  final Dio _dio;

  // ── Queries ──────────────────────────────────────────────────────────────────

  Future<PaginatedResponse<AuditorDto>> getAll({
    int page = 1,
    int size = 50,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get(
        ApiConstants.auditores,
        queryParameters: <String, dynamic>{'page': page, 'size': size},
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        AuditorDto.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuditorDto> getById(String id) async {
    try {
      final Response<dynamic> response =
          await _dio.get('${ApiConstants.auditores}/$id');
      return AuditorDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────────

  /// [data] must include: usuario_id, nombre, email, region.
  Future<AuditorDto> create(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.post(ApiConstants.auditores, data: data);
      return AuditorDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuditorDto> update(String id, Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.put('${ApiConstants.auditores}/$id', data: data);
      return AuditorDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.auditores}/$id');
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
