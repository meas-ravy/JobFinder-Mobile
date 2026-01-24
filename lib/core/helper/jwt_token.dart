import 'package:job_finder/core/helper/typedef.dart';

class AuthTokenPair {
  const AuthTokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokenPair.fromJson(DataMap json) {
    return AuthTokenPair(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  DataMap toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
