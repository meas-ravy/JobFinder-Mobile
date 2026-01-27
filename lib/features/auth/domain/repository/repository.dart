import 'package:job_finder/core/helper/typedef.dart';

abstract class AuthRepository {
  ResultFuture<DataMap> sendOtp(String phoneNumber);
  ResultFuture<DataMap> resendOtp(String phoneNumber);
  ResultFuture<DataMap> verifyOtp(String phoneNumber, String otpCode);
  ResultFuture<DataMap> oauthGoogle({
    required String idToken,
    required String accessToken,
  });
  ResultFuture<DataMap> oauthLinkedIn({
    required String authorizationCode,
    required String redirectUrl,
  });
  ResultFuture<DataMap> selectRole({required String role});
  ResultFuture<DataMap> logout();
}
