import 'package:job_finder/core/helper/typedef.dart';

class VerifyOtpModel {
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpModel({required this.phoneNumber, required this.otpCode});

  DataMap toJson() {
    return {'phone': phoneNumber, 'otp': otpCode};
  }

  factory VerifyOtpModel.fromJson(DataMap fromJson) {
    return VerifyOtpModel(
      phoneNumber: fromJson['phone'],
      otpCode: fromJson['otp'],
    );
  }
}
