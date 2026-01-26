import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/auth/data/repository_imp/repository_imp.dart';
import 'package:job_finder/features/auth/data/server/auth_server.dart';
import 'package:job_finder/features/auth/domain/repository/repository.dart';
import 'package:job_finder/features/auth/domain/usecase/auth_usecase.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_controller.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_state.dart';

final authServerProvider = Provider<AuthServer>((ref) {
  return AuthServerImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authServerProvider));
});

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

final resendOtpUseCaseProvider = Provider<ResendOtpUseCase>((ref) {
  return ResendOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final googleOAuthUseCaseProvider = Provider<GoogleOAuthUseCase>((ref) {
  return GoogleOAuthUseCase(ref.watch(authRepositoryProvider));
});

final linkedInOAuthUseCaseProvider = Provider<LinkedInOAuthUseCase>((ref) {
  return LinkedInOAuthUseCase(ref.watch(authRepositoryProvider));
});

final selectRoleUseCaseProvider = Provider<SelectRoleUseCase>((ref) {
  return SelectRoleUseCase(ref.watch(authRepositoryProvider));
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
      resendOtpUseCase: ref.watch(resendOtpUseCaseProvider),
      verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
      googleOAuthUseCase: ref.watch(googleOAuthUseCaseProvider),
      linkedInOAuthUseCase: ref.watch(linkedInOAuthUseCaseProvider),
      selectRoleUseCase: ref.watch(selectRoleUseCaseProvider),
      googleSignIn: ref.watch(googleSignInProvider),
    );
  },
);
