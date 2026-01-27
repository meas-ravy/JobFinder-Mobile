import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/auth/data/server/auth_server.dart';
import 'package:job_finder/features/auth/domain/repository/repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._authServer);

  final AuthServer _authServer;

  @override
  ResultFuture<DataMap> sendOtp(String phoneNumber) {
    return _authServer.sendOtp(phoneNumber);
  }

  @override
  ResultFuture<DataMap> resendOtp(String phoneNumber) {
    return _authServer.resendOtp(phoneNumber);
  }

  @override
  ResultFuture<DataMap> verifyOtp(String phoneNumber, String otpCode) {
    return _authServer.verifyOtp(phoneNumber, otpCode);
  }

  @override
  ResultFuture<DataMap> oauthGoogle({
    required String idToken,
    required String accessToken,
  }) {
    return _authServer.oauthGoogle(idToken: idToken, accessToken: accessToken);
  }

  @override
  ResultFuture<DataMap> oauthLinkedIn({
    required String authorizationCode,
    required String redirectUrl,
  }) {
    return _authServer.oauthLinkedIn(
      authorizationCode: authorizationCode,
      redirectUrl: redirectUrl,
    );
  }

  @override
  ResultFuture<DataMap> selectRole({required String role}) {
    return _authServer.selectRole(role: role);
  }

  @override
  ResultFuture<DataMap> logout() {
    return _authServer.logout();
  }
}
