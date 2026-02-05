import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/app_lock_recovery_overlay.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/app_lock_keypad_view.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/app_lock_cover_view.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;
  final String? title;
  final String? subtitle;
  const AppLockScreen({super.key, this.onUnlocked, this.title, this.subtitle});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final BiometricService _biometricService = BiometricService();
  String _pin = '';
  bool _isBiometricAvailable = false;
  String _errorMessage = '';
  bool _showKeypad = false;
  bool _showRecovery = false;
  String? _recoveryQuestion;
  final TextEditingController _recoveryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (isEnabled) {
      final authenticated = await _biometricService.authenticate(
        reason: 'Unlock the app',
      );
      if (authenticated) {
        if (widget.onUnlocked != null) {
          widget.onUnlocked!();
        } else {
          final navigator = Navigator.maybeOf(context);
          if (navigator != null && navigator.canPop()) {
            navigator.pop(true);
          }
        }
      }
    }

    final isSupported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    setState(() {
      _isBiometricAvailable = isSupported && canCheck;
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      if (_pin.length < 4) {
        _pin += number;
      }
      if (_pin.length == 4) {
        _verifyPin();
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _verifyPin() async {
    final isValid = await _biometricService.verifyAppPin(_pin);
    if (isValid) {
      if (widget.onUnlocked != null) {
        widget.onUnlocked!();
      } else {
        final navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) {
          navigator.pop(true);
        }
      }
    } else {
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _recoveryController.dispose();
    super.dispose();
  }

  Future<void> _onForgotPin() async {
    final question = await _biometricService.getSecurityQuestion();
    if (question == null) {
      _showErrorSnackBar('No security question set. Please contact support.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _recoveryQuestion = question;
      _showRecovery = true;
      _recoveryController.clear();
    });
  }

  Future<void> _verifyRecovery() async {
    final answer = _recoveryController.text;
    if (answer.isEmpty) return;

    final isValid = await _biometricService.verifySecurityAnswer(answer);
    if (isValid) {
      await _biometricService.deleteAllSecurityData();
      if (widget.onUnlocked != null) {
        widget.onUnlocked!();
      } else {
        final navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) {
          navigator.pop(true);
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect answer. Recovery failed.';
        _showRecovery = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    final canPop = navigator?.canPop() ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showRecovery) {
          setState(() => _showRecovery = false);
        } else if (_showKeypad) {
          setState(() => _showKeypad = false);
        } else {
          if (canPop) {
            navigator?.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _showKeypad ? 4 : 6,
                  sigmaY: _showKeypad ? 4 : 6,
                ),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: _showKeypad ? 0.8 : 0.5,
                  ),
                ),
              ),
            ),

            // Content
            _showKeypad
                ? AppLockKeypadView(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    pin: _pin,
                    errorMessage: _errorMessage,
                    isBiometricAvailable: _isBiometricAvailable,
                    canPop: canPop,
                    onNumberPressed: _onNumberPressed,
                    onBackspace: _onBackspace,
                    onBiometricPressed: _checkBiometrics,
                    onBack: () {
                      if (canPop) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _showKeypad = false);
                      }
                    },
                  )
                : AppLockCoverView(
                    onUnlock: () => setState(() => _showKeypad = true),
                    onForgotPin: _onForgotPin,
                  ),

            // Internal Recovery Overlay
            if (_showRecovery)
              AppLockRecoveryOverlay(
                recoveryQuestion: _recoveryQuestion ?? 'Loading...',
                controller: _recoveryController,
                onDismiss: () => setState(() => _showRecovery = false),
                onVerify: _verifyRecovery,
              ),
          ],
        ),
      ),
    );
  }
}
