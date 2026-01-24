import 'package:job_finder/core/helper/typedef.dart';

class RefreshTokenDTO {
  RefreshTokenDTO({required this.refreshToken, required this.accessToken});

  final String refreshToken, accessToken;

  DataMap toJson() {
    return {'refreshToken': refreshToken, 'accessToken': accessToken};
  }
}
