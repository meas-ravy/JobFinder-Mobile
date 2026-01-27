import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/routes/app_route.dart';

/// Intercepts 401 responses, clears stored auth data, and redirects to login
class UnauthorizedInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear stored token and role
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      await storage.delete();
      await storage.deleteRole();

      // Navigate to login using the global navigator key
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        GoRouter.of(context).go(AppPath.sendOtp);
      }
    }

    // Pass the error along
    handler.next(err);
  }
}
