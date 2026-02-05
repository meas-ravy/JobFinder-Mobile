import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/app_lock_screen.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();
  bool _isLocked = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _biometricService.lockNotifier.addListener(_onRemoteLockChange);
    _initialLockCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _biometricService.lockNotifier.removeListener(_onRemoteLockChange);
    super.dispose();
  }

  void _onRemoteLockChange() {
    if (_biometricService.lockNotifier.value) {
      _lockApp();
      _biometricService.lockNotifier.value = false; // Reset after reading
    }
  }

  Future<void> _initialLockCheck() async {
    final isEnabled = await _biometricService.isAppLockEnabled();
    final hasPin = await _biometricService.hasAppPin();
    if (isEnabled && hasPin) {
      setState(() {
        _isLocked = true;
        _initialized = true;
      });
    } else {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockApp();
    }
  }

  Future<void> _lockApp() async {
    final isEnabled = await _biometricService.isAppLockEnabled();
    final hasPin = await _biometricService.hasAppPin();
    if (isEnabled && hasPin) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  void _unlockApp() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      children: [
        widget.child,
        if (_isLocked) AppLockScreen(onUnlocked: _unlockApp),
      ],
    );
  }
}
