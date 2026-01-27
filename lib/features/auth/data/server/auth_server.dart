import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/error.dart';
import 'package:job_finder/core/helper/error_message.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/auth/data/model/sent_otp_model.dart';
import 'package:job_finder/features/auth/data/model/verify_otp_model.dart';

abstract class AuthServer {
  ResultFuture<DataMap> sendOtp(String phoneNumber);
  ResultFuture<DataMap> resendOtp(String phoneNumber);
  ResultFuture<DataMap> verifyOtp(String phoneNumber, String otpCode);
  ResultFuture<DataMap> logout();
  ResultFuture<DataMap> oauthGoogle({
    required String idToken,
    required String accessToken,
  });
  ResultFuture<DataMap> oauthLinkedIn({
    required String authorizationCode,
    required String redirectUrl,
  });
  ResultFuture<DataMap> selectRole({required String role});
}

class AuthServerImpl implements AuthServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  ResultFuture<DataMap> sendOtp(String phoneNumber) async {
    try {
      final response = await dio.post(
        ApiEnpoint.sentOtp,
        data: SentOtpModel(phoneNumber: phoneNumber).toJson(),
      );
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> resendOtp(String phoneNumber) async {
    try {
      final response = await dio.post(
        ApiEnpoint.resendOtp,
        data: SentOtpModel(phoneNumber: phoneNumber).toJson(),
      );
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final response = await dio.post(
        ApiEnpoint.verifyOtp,
        data: VerifyOtpModel(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
        ).toJson(),
      );
      final data = response.data;
      if (data is DataMap) {
        final accessToken = data['accessToken'];
        if (accessToken is String && accessToken.isNotEmpty) {
          final tokenStorage = TokenStorageImpl(const FlutterSecureStorage());
          await tokenStorage.write(
            // OTP token is temporary: it only authorizes (select-role)
            // After role selection, we overwrite storage with the role token
            accessToken,
          );
        }
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> oauthGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    try {
      final response = await dio.post(
        ApiEnpoint.oauth,
        data: {
          'provider': 'Google',
          'idToken': idToken,
          'accessToken': accessToken,
        },
      );
      final data = response.data;
      if (data is DataMap) {
        final jwtAccess = data['accessToken'];
        if (jwtAccess is String && jwtAccess.isNotEmpty) {
          final tokenStorage = TokenStorageImpl(const FlutterSecureStorage());
          await tokenStorage.write(jwtAccess);
        }
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> oauthLinkedIn({
    required String authorizationCode,
    required String redirectUrl,
  }) async {
    try {
      final response = await dio.post(
        ApiEnpoint.oauth,
        data: {
          'provider': 'LinkedIn',
          'authorizationCode': authorizationCode,
          'redirectUrl': redirectUrl,
        },
      );
      final data = response.data;
      if (data is DataMap) {
        final jwtAccess = data['accessToken'];
        if (jwtAccess is String && jwtAccess.isNotEmpty) {
          final tokenStorage = TokenStorageImpl(const FlutterSecureStorage());
          await tokenStorage.write(jwtAccess);
        }
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> selectRole({required String role}) async {
    try {
      final response = await dio.post(
        ApiEnpoint.roleSelect,
        data: {'role': role},
      );
      final data = response.data;
      if (data is DataMap) {
        final tokenUpdated = data['tokenUpdated'] == true;
        final roleAccessToken = data['accessToken'];
        final tokenStorage = TokenStorageImpl(const FlutterSecureStorage());

        // Always persist selected role locally (used for startup routing).
        await tokenStorage.writeRole(role);

        // Only overwrite the token if backend says it's updated.
        if (tokenUpdated &&
            roleAccessToken is String &&
            roleAccessToken.isNotEmpty) {
          await tokenStorage.write(roleAccessToken);
        }
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> logout() async {
    try {
      final response = await dio.post(ApiEnpoint.logout);
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }
}
