import 'package:shared_preferences/shared_preferences.dart';

/// Manages JWT persistence via [SharedPreferences].
///
/// All methods are static — no instantiation needed.
/// Keys are kept private to this class; callers never touch raw strings.
class TokenStorage {
  TokenStorage._();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Persists both tokens and user data after a successful login.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userName,
    String? userRole,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    if (userName != null) await prefs.setString(_keyUserName, userName);
    if (userRole != null) await prefs.setString(_keyUserRole, userRole);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns the stored access token, or `null` if absent.
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Returns the stored refresh token, or `null` if absent.
  static Future<String?> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<String?> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Removes both tokens and user info.
  static Future<void> clearTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserRole);
  }

  // ── Status ─────────────────────────────────────────────────────────────────

  /// Returns `true` when a non-empty access token is stored.
  static Future<bool> isLoggedIn() async {
    final String? token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
