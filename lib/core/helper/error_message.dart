import 'package:dio/dio.dart';

String errorMessage(int statusCode, DioException exception) {
  switch (statusCode) {
    case 400:
      return 'Bad request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not found';
    case 500:
      return 'Server error';
    default:
      return exception.message ?? 'Unexpected error';
  }
}
