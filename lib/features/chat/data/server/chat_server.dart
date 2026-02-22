import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/error.dart';
import 'package:job_finder/core/helper/error_message.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';

abstract class ChatServer {
  ResultFuture<DataMap> getConversations();
  ResultFuture<DataMap> updateConversation(String id, DataMap body);
  ResultFuture<DataMap> getAgoraToken(String channelName);
  ResultFuture<DataMap> signalCall(DataMap body);
}

class ChatServerImpl implements ChatServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  ResultFuture<DataMap> getConversations() async {
    try {
      final response = await dio.get(ApiEnpoint.conversations);
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
  ResultFuture<DataMap> updateConversation(String id, DataMap body) async {
    try {
      final response = await dio.patch(
        ApiEnpoint.updateConversation(id),
        data: body,
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
  ResultFuture<DataMap> getAgoraToken(String channelName) async {
    try {
      final response = await dio.get(ApiEnpoint.getAgoraToken(channelName));
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
  ResultFuture<DataMap> signalCall(DataMap body) async {
    try {
      final response = await dio.post(ApiEnpoint.agoraCallSignal, data: body);
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
