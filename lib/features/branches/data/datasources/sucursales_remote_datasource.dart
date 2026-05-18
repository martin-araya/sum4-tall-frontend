import 'package:dio/dio.dart';

import 'package:auditchain/core/constants/api_constants.dart';
import 'package:auditchain/core/network/dio_client.dart';
import 'package:auditchain/core/network/paginated_response.dart';
import '../models/sucursal_dto.dart';

/// Remote datasource for the /sucursales resource.
class SucursalesRemoteDatasource {
  SucursalesRemoteDatasource() : _dio = DioClient.getInstance();

  final Dio _dio;

  // ── Queries ──────────────────────────────────────────────────────────────────

  /// Returns a paginated list of branches.
  ///
  /// [region] is optional; omit to return all regions.
  Future<PaginatedResponse<SucursalDto>> getAll({
    int page = 1,
    int size = 50,
    String? region,
  }) async {
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (region != null) params['region'] = region;

      final Response<dynamic> response = await _dio.get(
        ApiConstants.sucursales,
        queryParameters: params,
      );

      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        SucursalDto.fromJson,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Returns a single branch by [id].
  Future<SucursalDto> getById(String id) async {
    try {
      final Response<dynamic> response =
          await _dio.get('${ApiConstants.sucursales}/$id');
      return SucursalDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────────

  Future<SucursalDto> create(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.post(ApiConstants.sucursales, data: data);
      return SucursalDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SucursalDto> update(String id, Map<String, dynamic> data) async {
    try {
      final Response<dynamic> response =
          await _dio.put('${ApiConstants.sucursales}/$id', data: data);
      return SucursalDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('${ApiConstants.sucursales}/$id');
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
