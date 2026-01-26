import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
import 'package:job_finder/features/auth/domain/repository/repository.dart';

class SendOtpParams {
  const SendOtpParams({required this.phoneNumber});
  final String phoneNumber;
}

class ResendOtpParams {
  const ResendOtpParams({required this.phoneNumber});
  final String phoneNumber;
}

class VerifyOtpParams {
  const VerifyOtpParams({required this.phoneNumber, required this.otpCode});
  final String phoneNumber;
  final String otpCode;
}

class GoogleOAuthParams {
  const GoogleOAuthParams({required this.idToken, required this.accessToken});
  final String idToken;
  final String accessToken;
}

class SendOtpUseCase extends UseCaseWithParams<DataMap, SendOtpParams> {
  const SendOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(SendOtpParams params) {
    return _repository.sendOtp(params.phoneNumber);
  }
}

class ResendOtpUseCase extends UseCaseWithParams<DataMap, ResendOtpParams> {
  const ResendOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(ResendOtpParams params) {
    return _repository.resendOtp(params.phoneNumber);
  }
}

class VerifyOtpUseCase extends UseCaseWithParams<DataMap, VerifyOtpParams> {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(VerifyOtpParams params) {
    return _repository.verifyOtp(params.phoneNumber, params.otpCode);
  }
}

class GoogleOAuthUseCase extends UseCaseWithParams<DataMap, GoogleOAuthParams> {
  const GoogleOAuthUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(GoogleOAuthParams params) {
    return _repository.oauthGoogle(
      idToken: params.idToken,
      accessToken: params.accessToken,
    );
  }
}

class LinkedInOAuthParams {
  const LinkedInOAuthParams({
    required this.authorizationCode,
    required this.redirectUrl,
  });
  final String authorizationCode;
  final String redirectUrl;
}

class LinkedInOAuthUseCase
    extends UseCaseWithParams<DataMap, LinkedInOAuthParams> {
  const LinkedInOAuthUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(LinkedInOAuthParams params) {
    return _repository.oauthLinkedIn(
      authorizationCode: params.authorizationCode,
      redirectUrl: params.redirectUrl,
    );
  }
}

class SelectRoleParams {
  const SelectRoleParams({required this.role});
  final String role;
}

class SelectRoleUseCase extends UseCaseWithParams<DataMap, SelectRoleParams> {
  const SelectRoleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  ResultFuture<DataMap> call(SelectRoleParams params) {
    return _repository.selectRole(role: params.role);
  }
}
