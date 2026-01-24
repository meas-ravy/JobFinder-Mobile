import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/networks/logger_interceptor.dart';
import 'package:job_finder/core/networks/refresh_token_interceptor.dart';

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

  // Set up token refresh interceptor
  final tokenRefreshInterceptor = RefreshTokenInterceptor(tokenStorage);
  final fresh = tokenRefreshInterceptor.refresh;

  // Add the logger interceptor to Dio
  dio.interceptors.add(LoggerInterceptor());

  // Add the Fresh interceptor to Dio
  dio.interceptors.add(fresh);

  // Log out listener to handle authentication failures
  fresh.authenticationStatus.listen((status) {
    if (status == AuthenticationStatus.unauthenticated) {
      // Navigate to login screen or show login dialog
      print('User needs to login again');
    }
  });

  return dio;
}
