import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service to handle local biometric authentication (fingerprint, face ID, PIN)
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<bool> lockNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> settingsNotifier = ValueNotifier<int>(0);
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _appPinKey = 'app_pin';
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _securityQuestionKey = 'security_question';
  static const String _securityAnswerKey = 'security_answer';

  /// Check if app lock is enabled
  Future<bool> isAppLockEnabled() async {
    try {
      final value = await _storage.read(key: _appLockEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable app lock
  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(key: _appLockEnabledKey, value: enabled.toString());
    settingsNotifier.value++;
  }

  /// Set the 4-digit App PIN
  Future<void> setAppPin(String pin) async {
    await _storage.write(key: _appPinKey, value: pin);
    settingsNotifier.value++;
  }

  /// Verify the App PIN
  Future<bool> verifyAppPin(String pin) async {
    final savedPin = await _storage.read(key: _appPinKey);
    return savedPin == pin;
  }

  /// Check if an App PIN is already set
  Future<bool> hasAppPin() async {
    final savedPin = await _storage.read(key: _appPinKey);
    return savedPin != null && savedPin.isNotEmpty;
  }

  /// Delete the App PIN
  Future<void> deleteAppPin() async {
    await _storage.delete(key: _appPinKey);
    settingsNotifier.value++;
  }

  /// Save security question and answer
  Future<void> saveSecurityData(String question, String answer) async {
    await _storage.write(key: _securityQuestionKey, value: question);
    await _storage.write(
      key: _securityAnswerKey,
      value: answer.toLowerCase().trim(),
    );
    settingsNotifier.value++;
  }

  /// Get the saved security question
  Future<String?> getSecurityQuestion() async {
    return await _storage.read(key: _securityQuestionKey);
  }

  /// Verify the security answer
  Future<bool> verifySecurityAnswer(String answer) async {
    final savedAnswer = await _storage.read(key: _securityAnswerKey);
    return savedAnswer == answer.toLowerCase().trim();
  }

  /// Delete all security data
  Future<void> deleteAllSecurityData() async {
    await _storage.delete(key: _appPinKey);
    await _storage.delete(key: _securityQuestionKey);
    await _storage.delete(key: _securityAnswerKey);
    await setAppLockEnabled(false);
    settingsNotifier.value++;
  }

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric sensors are available (fingerprint/face ID enrolled)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if user has enabled biometric authentication in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable biometric authentication in app settings
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
    settingsNotifier.value++;
  }

  /// Authenticate user with biometric (fingerprint, face ID) or device credentials (PIN/password/pattern)
  /// Returns true if authentication successful, false otherwise
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await canCheckBiometrics();
      if (!canCheck && biometricOnly) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // Handle specific errors
      if (e.code == 'NotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'PasscodeNotSet') {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Stop ongoing authentication (if user navigates away)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get a human-readable string of available biometric types
  Future<String> getAvailableBiometricString() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return 'PIN/Password';

    final types = <String>[];
    if (biometrics.contains(BiometricType.fingerprint)) {
      types.add('Fingerprint');
    }

    return types.isEmpty
        ? 'PIN/Password'
        : '${types.join(' or ')} or PIN/Password';
  }
}
