import 'package:job_finder/core/helper/typedef.dart';

enum AuthAction {
  sendOtp,
  resendOtp,
  verifyOtp,
  googleSignIn,
  linkedInSignIn,
  selectRole,
}

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastAction,
  });

  final bool isLoading;
  final String? errorMessage;
  final DataMap? data;
  final AuthAction? lastAction;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    DataMap? data,
    AuthAction? lastAction,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      lastAction: lastAction ?? this.lastAction,
    );
  }
}
