import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/jwt_token.dart';
import 'package:job_finder/core/routes/app_navigator.dart';

/// Handles "token expired / invalid" by clearing saved auth and sending the user
/// back to login (Send OTP screen). Backend does not support refresh tokens.
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor(this._tokenStorage);

  final TokenStorage<AuthToken> _tokenStorage;

  static bool _isRedirecting = false;

  bool _isAuthEndpoint(RequestOptions options) {
    final path = options.path;
    return path.contains(ApiEnpoint.sentOtp) ||
        path.contains(ApiEnpoint.verifyOtp) ||
        path.contains(ApiEnpoint.resendOtp) ||
        path.contains(ApiEnpoint.oauth) ||
        path.contains(ApiEnpoint.logout) ||
        path.contains(ApiEnpoint.roleSelect);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 &&
        !_isRedirecting &&
        !_isAuthEndpoint(err.requestOptions)) {
      _isRedirecting = true;
      try {
        await _tokenStorage.delete();
      } catch (_) {
        // Ignore storage errors; we still redirect to login.
      } finally {
        AppNavigator.goToSendOtpAndClearStack();
        _isRedirecting = false;
      }
    }
    handler.next(err);
  }
}
