import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';

class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor(this._tokenStorage);

  final TokenStorage<String> _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
