import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/networks/auth_header_interceptor.dart';
import 'package:job_finder/core/networks/logger_interceptor.dart';
import 'package:job_finder/core/networks/unauthorized_interceptor.dart';

Dio setupAuthenticatedDio(String baseUrl) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Set up token storage
  final secureStorage = const FlutterSecureStorage();
  final tokenStorage = TokenStorageImpl(secureStorage);

  // Add the logger interceptor to Dio
  dio.interceptors.add(LoggerInterceptor());

  // Redirect to login when token expires (401).
  dio.interceptors.add(UnauthorizedInterceptor(tokenStorage));

  // Add auth header interceptor (no automatic refresh; access token is long-lived)
  dio.interceptors.add(AuthHeaderInterceptor(tokenStorage));

  return dio;
}
