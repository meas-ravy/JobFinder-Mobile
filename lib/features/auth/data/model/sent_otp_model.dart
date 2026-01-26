import 'package:job_finder/core/helper/typedef.dart';

class SentOtpModel {
  final String phoneNumber;

  const SentOtpModel({required this.phoneNumber});

  DataMap toJson() {
    return {'phone': phoneNumber};
  }

  factory SentOtpModel.fromJson(DataMap fromJson) {
    return SentOtpModel(phoneNumber: fromJson['phone']);
  }
}
