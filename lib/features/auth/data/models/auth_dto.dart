/// Request body for POST /auth/login.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
      };
}

/// Successful response from POST /auth/login.
///
/// The backend returns snake_case keys; [fromJson] maps them to camelCase fields.
class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    this.userName,
    this.userRole,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String? userName;
  final String? userRole;

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String,
        userName: json['user_name'] as String?,
        userRole: json['user_role'] as String?,
      );
}
