import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/auth/presentation/screen/app_role_screen.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_state.dart';
import 'package:job_finder/features/auth/presentation/widget/otp_box.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/shared/components/primary_button.dart';

class VeriffyOtpScreen extends ConsumerStatefulWidget {
  const VeriffyOtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<VeriffyOtpScreen> createState() => _VeriffyOtpScreenState();
}

class _VeriffyOtpScreenState extends ConsumerState<VeriffyOtpScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  String? _otpError;
  bool _isApplyingOtp = false;
  late final ProviderSubscription _authSub;
  Timer? _resendTimer;
  int _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });

    _authSub = ref.listenManual(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (!mounted) return;
        if (next.lastAction != AuthAction.verifyOtp) return;

        if (next.errorMessage != null) {
          setState(() {
            _otpError = next.errorMessage;
          });
          return;
        }

        final data = next.data;
        final success = data is Map ? data['success'] : null;
        if (data != null && (success == null || success == true)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppRoleScreen()),
          );
        }
      }
    });

    _startResendTimer();
  }

  @override
  void dispose() {
    _authSub.close();
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() {
          _resendSeconds = 0;
        });
        return;
      }
      setState(() {
        _resendSeconds -= 1;
      });
    });
  }

  void _handleChanged(int index, String value) {
    if (_isApplyingOtp) return;
    if (value.length > 1) {
      _applyOtp(value);
      return;
    }

    if (value.isNotEmpty && index < 4 - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    if (_otpError != null) {
      final otp = _controllers.map((c) => c.text).join();
      if (otp.length == 4) {
        setState(() {
          _otpError = null;
        });
      }
    }
  }

  void _handleBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _applyOtp(String otp) {
    _isApplyingOtp = true;
    final chars = otp.replaceAll(RegExp(r'\D'), '').split('');
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < chars.length ? chars[i] : '';
    }
    _controllers.last.selection = TextSelection.collapsed(
      offset: _controllers.last.text.length,
    );
    if (chars.length >= 4) {
      FocusScope.of(context).unfocus();
      TextInput.finishAutofillContext(shouldSave: true);
    }
    if (_otpError != null) {
      setState(() {
        _otpError = null;
      });
    }
    _isApplyingOtp = false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: AppSvgIcon(
                      assetName: AppIcon.arrowLefe,
                      size: 30,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppSvgIcon(
                  assetName: AppIcon.appLogoTwo,
                  size: 82,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 55),
                Text(
                  'OTP Verification',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the verification code we just sent to\n your phone number',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    // height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),
                AutofillGroup(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _handleChanged(index, value),
                        onBackspace: () => _handleBackspace(index),
                        isLast: index == 4 - 1,
                        autofill: index == 0,
                        index: index + 1,
                        total: 4,
                        hasError: _otpError != null,
                      ),
                    ),
                  ),
                ),
                if (_otpError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _otpError!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 65),
                PrimaryButton(
                  label: 'Verification',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          final otp = _controllers.map((c) => c.text).join();
                          if (otp.length != 4) {
                            setState(() {
                              _otpError = 'Please enter OTP code';
                            });
                            return;
                          }
                          ref
                              .read(authControllerProvider.notifier)
                              .verifyOtp(widget.phoneNumber, otp);
                        },
                ),
                const SizedBox(height: 65),
                Center(
                  child: _resendSeconds > 0
                      ? RichText(
                          text: TextSpan(
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 15,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                            children: [
                              const TextSpan(text: 'Resend OTP in '),
                              TextSpan(
                                text: '${_resendSeconds}s',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .resendOtp(widget.phoneNumber);
                                  if (!mounted) return;
                                  _startResendTimer();
                                },
                          child: Text(
                            'Resend OTP',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
