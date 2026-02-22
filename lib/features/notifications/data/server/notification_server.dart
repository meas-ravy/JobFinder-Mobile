import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/error.dart';
import 'package:job_finder/core/helper/error_message.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';

abstract class NotificationServer {
  ResultFuture<DataMap> getNotifications({String? role});
  ResultFuture<DataMap> markAsRead(String id);
}

class NotificationServerImpl implements NotificationServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  ResultFuture<DataMap> getNotifications({String? role}) async {
    try {
      final response = await dio.get(
        ApiEnpoint.notifications,
        queryParameters: role != null ? {'role': role} : null,
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
  ResultFuture<DataMap> markAsRead(String id) async {
    try {
      final response = await dio.patch(
        ApiEnpoint.markNotificationRead,
        data: {'id': id},
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
}
