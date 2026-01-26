import 'package:job_finder/core/helper/typedef.dart';

/// Single access token used across the app (backend does not support refresh).
class AuthToken {
  const AuthToken({required this.accessToken});

  final String accessToken;

  /// Backward compatible: accepts legacy JSON that may also include `refreshToken`.
  factory AuthToken.fromJson(DataMap json) {
    return AuthToken(accessToken: (json['accessToken'] as String?) ?? '');
  }

  DataMap toJson() {
    return {'accessToken': accessToken};
  }
}
