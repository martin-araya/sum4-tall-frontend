import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Keys used to persist tokens in [SharedPreferences].
abstract final class _StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

/// Singleton Dio client pre-configured for the AuditChain API.
///
/// Interceptors added (in order):
///   1. [_AuthInterceptor]  — attaches `Authorization: Bearer <token>` header.
///   2. [_ErrorInterceptor] — clears stored tokens on 401 responses.
class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json',
        },
      ),
    )
      ..interceptors.add(_AuthInterceptor())
      ..interceptors.add(_ErrorInterceptor());
  }

  static final DioClient _instance = DioClient._();
  late final Dio _dio;

  /// Returns the shared [Dio] instance ready to use.
  static Dio getInstance() => _instance._dio;
}

// ── Auth interceptor ──────────────────────────────────────────────────────────

/// Reads the stored access token and injects it as a Bearer header.
/// Skips the header for [ApiConstants.authLogin] so the login request
/// can reach the backend without a (potentially stale) token.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool isLoginRequest =
        options.path == ApiConstants.authLogin;

    if (!isLoginRequest) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(_StorageKeys.accessToken);

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}

// ── Error interceptor ─────────────────────────────────────────────────────────

/// Clears both tokens from local storage when the server returns 401.
/// Does not act on login failures — an incorrect password also yields 401
/// but there are no tokens to clear at that point anyway.
class _ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool is401 = err.response?.statusCode == 401;
    final bool isLoginRequest =
        err.requestOptions.path == ApiConstants.authLogin;

    if (is401 && !isLoginRequest) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_StorageKeys.accessToken);
      await prefs.remove(_StorageKeys.refreshToken);
    }

    handler.next(err);
  }
}
