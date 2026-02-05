import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/app_lock_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/pin_setup_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_question_screen.dart';
import 'package:job_finder/shared/widget/section_title.dart';
import 'package:job_finder/shared/widget/setting_switch_tile.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricEnabled = false;
  bool _isAppLockEnabled = false;
  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  String? _securityQuestion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _biometricService.settingsNotifier.addListener(_checkBiometricStatus);
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _biometricService.settingsNotifier.removeListener(_checkBiometricStatus);
    super.dispose();
  }

  Future<void> _checkBiometricStatus() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final isAppLockEnabled = await _biometricService.isAppLockEnabled();
    final question = await _biometricService.getSecurityQuestion();

    if (mounted) {
      setState(() {
        _isDeviceSupported = isSupported;
        _canCheckBiometrics = canCheck;
        _isBiometricEnabled = isEnabled;
        _isAppLockEnabled = isAppLockEnabled;
        _securityQuestion = question;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      final set = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupScreen()),
      );
      if (set != true) return;
      await _biometricService.setAppLockEnabled(true);
      // Trigger the lock screen immediately to verify
      _biometricService.lockNotifier.value = true;
    } else {
      // Require verification before disabling
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AppLockScreen(
            title: 'Verify PIN',
            subtitle: 'Enter your current PIN to disable App Lock',
          ),
        ),
      );

      if (verified == true) {
        await _biometricService.setAppLockEnabled(false);
        await _biometricService.deleteAppPin();
      } else {
        return; // Don't update UI if cancelled or failed
      }
    }
    _checkBiometricStatus();
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_isDeviceSupported || !_canCheckBiometrics) {
      _showErrorDialog(
        'Biometric Not Available',
        'Your device does not support biometric authentication or you haven\'t enrolled any biometric data (fingerprint/face).',
      );
      return;
    }

    if (value) {
      // User wants to enable - authenticate first
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric security',
      );

      if (!mounted) return;

      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
      }
    } else {
      // User wants to disable - authenticate first
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to disable biometric security',
      );

      if (!mounted) return;

      if (authenticated) {
        await _biometricService.setBiometricEnabled(false);
        setState(() => _isBiometricEnabled = false);
      } else {
        _showErrorSnackBar('Authentication failed');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: const Text('Security Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  SectionTitle(title: 'App Security', textTheme: textTheme),
                  SettingsSwitchTile(
                    iconData: Icons.lock_outline,
                    title: 'Enable App Lock',
                    subtitle: 'Require PIN to open the app',
                    value: _isAppLockEnabled,
                    onTap: () => _toggleAppLock(!_isAppLockEnabled),
                    onChanged: _toggleAppLock,
                  ),
                  const SizedBox(height: 24),

                  SettingsSwitchTile(
                    iconData: Icons.fingerprint,
                    title: 'Enable Biometrics',
                    subtitle: 'Use fingerprint to unlock',
                    value: _isBiometricEnabled,
                    onTap: _isDeviceSupported && _canCheckBiometrics
                        ? () => _toggleBiometric(!_isBiometricEnabled)
                        : null,
                    onChanged: _isDeviceSupported && _canCheckBiometrics
                        ? _toggleBiometric
                        : null,
                  ),
                  if (_securityQuestion != null) ...[
                    const SizedBox(height: 24),
                    SectionTitle(
                      title: 'Recovery Settings',
                      textTheme: textTheme,
                    ),
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.help_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: const Text('Security Question'),
                        subtitle: Text(
                          _securityQuestion!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SecurityQuestionScreen(),
                            ),
                          );
                          if (result == true) {
                            _checkBiometricStatus();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
