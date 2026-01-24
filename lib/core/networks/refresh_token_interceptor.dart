import 'package:fresh_dio/fresh_dio.dart';
import 'package:job_finder/core/helper/jwt_token.dart';

class RefreshTokenInterceptor {
  final TokenStorage<AuthTokenPair> _tokenStorage;
  RefreshTokenInterceptor(this._tokenStorage);

  Fresh<AuthTokenPair> get refresh => Fresh<AuthTokenPair>(
    tokenHeader: (token) {
      return {'Authorization': 'Bearer ${token.accessToken}'};
    },
    tokenStorage: _tokenStorage,
    refreshToken: (token, httpClient) async {
      try {
        final response = await httpClient.post(
          '/api/refresh-token',
          data: {
            'refreshToken': token!.refreshToken,
            'accessToken': token.accessToken,
          },
        );

        final newTokens = response.data;
        return AuthTokenPair(
          accessToken: newTokens['accessToken'],
          refreshToken: newTokens['refreshToken'],
        );
      } catch (e) {
        // If refresh fails, throw to trigger logout
        throw RevokeTokenException();
      }
    },
    shouldRefresh: (response) {
      return response?.statusCode == 401;
    },
  );
}
