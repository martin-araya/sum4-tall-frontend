import 'package:dio/dio.dart';

import 'package:auditchain/core/constants/api_constants.dart';
import 'package:auditchain/core/network/dio_client.dart';
import '../models/auth_dto.dart';

/// Handles all remote calls related to authentication.
class AuthRemoteDatasource {
  AuthRemoteDatasource() : _dio = DioClient.getInstance();

  final Dio _dio;

  /// Sends login credentials to the backend and returns the token pair.
  ///
  /// Throws [Exception] with a user-readable message on failure:
  ///   - 401 → 'Credenciales inválidas'
  ///   - other → detail field from the error body, or a generic message
  Future<TokenResponse> login(String email, String password) async {
    final LoginRequest request =
        LoginRequest(email: email, password: password);

    try {
      final Response<dynamic> response = await _dio.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      return TokenResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }

      final dynamic body = e.response?.data;
      final String? detail =
          body is Map ? body['detail']?.toString() : null;

      throw Exception(detail ?? 'Error de conexión con el servidor');
    }
  }

  /// Registers a new user.
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    String rol = 'auditor',
  }) async {
    try {
      await _dio.post(
        ApiConstants.authRegister,
        data: {
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
        },
      );
    } on DioException catch (e) {
      final dynamic body = e.response?.data;
      final String? detail =
          body is Map ? body['detail']?.toString() : null;

      throw Exception(detail ?? 'Error al registrar el usuario');
    }
  }
}
