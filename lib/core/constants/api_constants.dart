/// Centralizes all API configuration values and endpoint paths.
///
/// [baseUrl] is injected at build time via `--dart-define=API_URL`.
/// Falls back to the local development server when not defined.
class ApiConstants {
  ApiConstants._();

  // ── Base URL ────────────────────────────────────────────────────────────────

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://sum4-tall-backend-production.up.railway.app/api/v1',
  );

  // ── Timeouts ────────────────────────────────────────────────────────────────

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Auth endpoints ──────────────────────────────────────────────────────────

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // ── Resource endpoints ──────────────────────────────────────────────────────

  static const String sucursales = '/sucursales';
  static const String auditores = '/auditores';
  static const String auditorias = '/auditorias';
  static const String auditoriaStats = '/auditorias/stats';
  static const String usuariosMe = '/usuarios/me';
}
