import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:job_finder/core/helper/jwt_token.dart';

/// Adds `Authorization: Bearer <accessToken>` from secure token storage.
///
/// This project intentionally does NOT refresh tokens automatically.
class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor(this._tokenStorage);

  final TokenStorage<AuthToken> _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.read();
      if (token != null && token.accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${token.accessToken}';
      }
    } catch (_) {
      // Ignore storage errors; proceed without auth header.
    }
    handler.next(options);
  }
}
