import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/auth/domain/usecase/auth_usecase.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SendOtpUseCase sendOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required GoogleOAuthUseCase googleOAuthUseCase,
    required LinkedInOAuthUseCase linkedInOAuthUseCase,
    required SelectRoleUseCase selectRoleUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignIn googleSignIn,
  }) : _sendOtpUseCase = sendOtpUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _googleOAuthUseCase = googleOAuthUseCase,
       _selectRoleUseCase = selectRoleUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignIn = googleSignIn,
       super(const AuthState());

  final SendOtpUseCase _sendOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GoogleOAuthUseCase _googleOAuthUseCase;
  final SelectRoleUseCase _selectRoleUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignIn _googleSignIn;

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.sendOtp,
    );
    final result = await _sendOtpUseCase(
      SendOtpParams(phoneNumber: phoneNumber),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  Future<void> resendOtp(String phoneNumber) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.resendOtp,
    );
    final result = await _resendOtpUseCase(
      ResendOtpParams(phoneNumber: phoneNumber),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  Future<void> verifyOtp(String phoneNumber, String otpCode) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.verifyOtp,
    );
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(phoneNumber: phoneNumber, otpCode: otpCode),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.googleSignIn,
    );

    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final idToken = account.authentication.idToken;
      final authz = await account.authorizationClient.authorizeScopes(const [
        'email',
        'profile',
      ]);
      final accessToken = authz.accessToken;

      if (kDebugMode) {
        debugPrint(
          '[GoogleSignIn] email=${account.email} '
          'idToken=${idToken != null ? 'yes(len=${idToken.length})' : 'no'} '
          'accessTokenLen=${accessToken.length}',
        );
      }

      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google sign-in failed to return idToken',
        );
        return;
      }

      final result = await _googleOAuthUseCase(
        GoogleOAuthParams(idToken: idToken, accessToken: accessToken),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (data) {
          if (kDebugMode) {
            final jwtAccess = data['accessToken'];
            final jwtRefresh = data['refreshToken'];
            debugPrint(
              '[GoogleSignIn] backend ok '
              'jwtAccess=${jwtAccess is String ? 'yes(len=${jwtAccess.length})' : 'no'} '
              'jwtRefresh=${jwtRefresh is String ? 'yes(len=${jwtRefresh.length})' : 'no'}',
            );
          }
          state = state.copyWith(isLoading: false, data: data);
        },
      );
    } on GoogleSignInException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${e.code}: ${e.description ?? 'Google sign-in failed'}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> selectRole(String role) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.selectRole,
    );

    final result = await _selectRoleUseCase(SelectRoleParams(role: role));
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
        return true;
      },
    );
  }

  Future<bool> logout() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.logout,
    );

    final result = await _logoutUseCase();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (data) {
        state = const AuthState(); // Reset state on success
        return true;
      },
    );
  }
}
