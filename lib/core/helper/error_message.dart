import 'package:dio/dio.dart';
import 'package:job_finder/core/helper/typedef.dart';

String errorMessage(int statusCode, DioException exception) {
  final responseData = exception.response?.data;

  if (responseData is DataMap) {
    // Check for 'errors' array (validation errors)
    if (responseData.containsKey('errors') && responseData['errors'] is List) {
      final List errors = responseData['errors'];
      if (errors.isNotEmpty) {
        return errors.join('\n');
      }
    }
    // Check for 'message' or 'error' string
    if (responseData.containsKey('message')) {
      return responseData['message'].toString();
    }
    if (responseData.containsKey('error')) {
      return responseData['error'].toString();
    }
  }

  switch (statusCode) {
    case 400:
      return 'Validation failed. Please check your inputs.';
    case 401:
      return 'Session expired. Please sign in again.';
    case 403:
      return 'You do not have permission to perform this action.';
    case 404:
      return 'The requested resource was not found.';
    case 500:
      return 'Internal server error. Please try again later.';
    default:
      return exception.message ?? 'Unexpected connection error';
  }
}
