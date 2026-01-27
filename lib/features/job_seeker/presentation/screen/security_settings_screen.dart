import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';
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
  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  String _availableBiometrics = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final canCheck = await _biometricService.canCheckBiometrics();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final availableBiometrics = await _biometricService
        .getAvailableBiometricString();

    if (mounted) {
      setState(() {
        _isDeviceSupported = isSupported;
        _canCheckBiometrics = canCheck;
        _isBiometricEnabled = isEnabled;
        _availableBiometrics = availableBiometrics;
        _isLoading = false;
      });
    }
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
        _showSuccessSnackBar('Biometric authentication enabled');
      } else {
        _showErrorSnackBar('Authentication failed');
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
        _showSuccessSnackBar('Biometric authentication disabled');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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

  Future<void> _testBiometric() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Test biometric authentication',
    );

    if (!mounted) return;

    if (authenticated) {
      _showSuccessSnackBar('Authentication successful!');
    } else {
      _showErrorSnackBar('Authentication failed or cancelled');
    }
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
                  SectionTitle(
                    title: 'Biometric Authentication',
                    textTheme: textTheme,
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isDeviceSupported && _canCheckBiometrics
                                    ? Icons.fingerprint
                                    : Icons.lock_outline,
                                size: 32,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Device Status',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isDeviceSupported && _canCheckBiometrics
                                          ? 'Available: $_availableBiometrics'
                                          : 'Not available on this device',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    iconData: Icons.security,
                    title: 'Enable Biometric Login',
                    subtitle:
                        'Use fingerprint or PIN to access protected features',
                    value: _isBiometricEnabled,
                    onChanged: _isDeviceSupported && _canCheckBiometrics
                        ? _toggleBiometric
                        : null,
                  ),
                  if (_isBiometricEnabled) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.verified_user,
                          color: colorScheme.primary,
                        ),
                        title: const Text('Test Authentication'),
                        subtitle: const Text(
                          'Test your biometric authentication',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _testBiometric,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How it works',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Biometric authentication is stored locally on your device\n'
                            '• No biometric data is sent to our servers\n'
                            '• You can use fingerprint, face ID, or your device PIN\n'
                            '• Protected features require authentication to access',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
