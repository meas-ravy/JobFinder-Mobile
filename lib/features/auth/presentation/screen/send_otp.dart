import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_state.dart';
import 'package:job_finder/features/auth/presentation/screen/veriffy_otp.dart';
import 'package:job_finder/features/auth/presentation/widget/social_icon_button.dart';
import 'package:job_finder/shared/components/primary_button.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SendOtpScreen extends ConsumerStatefulWidget {
  const SendOtpScreen({super.key});

  @override
  ConsumerState<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends ConsumerState<SendOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;
  String? _socialMessage;
  String? _socialError;
  late final ProviderSubscription _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = ref.listenManual(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (!mounted) return;
        switch (next.lastAction) {
          case AuthAction.sendOtp:
            if (next.errorMessage != null) {
              setState(() {
                _phoneError = next.errorMessage;
              });
              return;
            }
            if (next.data != null) {
              final data = next.data!;
              final success = data['success'];
              if (success is bool && success == false) {
                setState(() {
                  _phoneError =
                      (data['message'] as String?) ?? 'Request failed';
                });
                return;
              }
              final phone = _normalizePhone(_phoneController.text);
              if (phone.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VeriffyOtpScreen(phoneNumber: phone),
                  ),
                );
              }
            }
            return;

          case AuthAction.googleSignIn:
          case AuthAction.linkedInSignIn:
            setState(() {
              _socialError = next.errorMessage;
              _socialMessage = next.errorMessage == null && next.data != null
                  ? 'Signed in successfully'
                  : null;
            });
            return;

          case AuthAction.resendOtp:
          case AuthAction.verifyOtp:
          case null:
            return;
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub.close();
    _phoneController.dispose();
    super.dispose();
  }

  String _stripCountryPrefix(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('855')) {
      digits = digits.substring(3);
    }
    return digits;
  }

  String _normalizePhone(String raw) {
    var local = _stripCountryPrefix(raw);
    if (local.startsWith('0')) {
      local = local.substring(1);
    }
    if (local.isEmpty) return '';
    return '+855$local';
  }

  bool _isValidLocalLength(String raw) {
    var local = _stripCountryPrefix(raw);
    if (local.startsWith('0')) {
      local = local.substring(1);
    }
    return local.length == 8 || local.length == 9;
  }

  String? _validatePhone(String raw) {
    var local = _stripCountryPrefix(raw);
    if (local.isEmpty) return 'Please enter phone number';
    if (local.startsWith('0')) {
      local = local.substring(1);
    }
    if (local.length < 8 || local.length > 9) {
      return 'Phone number is invalid';
    }
    return null;
  }

  void _stripLeadingZeroForDisplay() {
    final text = _phoneController.text;
    if (text.startsWith('0')) {
      final trimmed = text.replaceFirst(RegExp(r'^0+'), '');
      _phoneController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
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
          physics: NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSvgIcon(assetName: 'assets/image/jober.svg', size: 82),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "Login",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Welcome back to the app",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    errorText: _phoneError,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 20,
                            width: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'KH',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+855',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 22,
                            width: 1,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    suffixIcon: _isValidLocalLength(_phoneController.text)
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : null,
                  ),
                  onChanged: (_) {
                    _stripLeadingZeroForDisplay();
                    setState(() {
                      if (_phoneError != null) {
                        _phoneError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          final error = _validatePhone(_phoneController.text);
                          if (error != null) {
                            setState(() {
                              _phoneError = error;
                            });
                            return;
                          }
                          final phone = _normalizePhone(_phoneController.text);
                          ref
                              .read(authControllerProvider.notifier)
                              .sendOtp(phone);
                        },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: DottedLine(
                        dashColor: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OR',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DottedLine(
                        dashColor: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      assetName: AppIcon.google,
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      onTap: authState.isLoading
                          ? () {}
                          : () {
                              setState(() {
                                _socialError = null;
                                _socialMessage = null;
                              });
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();
                            },
                    ),
                    const SizedBox(width: 16),
                    SocialIconButton(
                      assetName: AppIcon.linkenin,
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      onTap: authState.isLoading
                          ? () {}
                          : () {
                              setState(() {
                                _socialError = null;
                                _socialMessage = null;
                              });
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithLinkedIn(context);
                            },
                    ),
                  ],
                ),
                if (_socialError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _socialError!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_socialMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _socialMessage!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
