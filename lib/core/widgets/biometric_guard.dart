import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';

/// Helper class to guard actions with biometric authentication
class BiometricGuard {
  static final BiometricService _biometricService = BiometricService();

  /// Execute an action only if biometric authentication succeeds
  /// Returns true if action was executed, false if authentication failed
  static Future<bool> guardAction({
    required BuildContext context,
    required VoidCallback action,
    String reason = 'Authenticate to continue',
  }) async {
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();

    if (!isBiometricEnabled) {
      // Biometric not enabled, execute action directly
      action();
      return true;
    }

    // Show authentication dialog
    final authenticated = await _biometricService.authenticate(reason: reason);

    if (authenticated) {
      action();
      return true;
    }

    return false;
  }

  /// Execute an async action only if biometric authentication succeeds
  /// Returns the result of the action, or null if authentication failed
  static Future<T?> guardAsyncAction<T>({
    required BuildContext context,
    required Future<T> Function() action,
    String reason = 'Authenticate to continue',
  }) async {
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();

    if (!isBiometricEnabled) {
      // Biometric not enabled, execute action directly
      return await action();
    }

    // Show authentication dialog
    final authenticated = await _biometricService.authenticate(reason: reason);

    if (authenticated) {
      return await action();
    }

    return null;
  }

  /// Show a confirmation dialog with biometric authentication
  static Future<bool> confirmWithBiometric({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    String biometricReason = 'Authenticate to confirm',
  }) async {
    // First show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    // Then authenticate with biometric
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();
    if (!isBiometricEnabled) return true;

    return await _biometricService.authenticate(reason: biometricReason);
  }
}

/// Example usage in your code:
/// 
/// // Protect a single action:
/// await BiometricGuard.guardAction(
///   context: context,
///   reason: 'Authenticate to delete account',
///   action: () {
///     // Delete account code here
///     print('Account deleted');
///   },
/// );
///
/// // Protect an async action:
/// final result = await BiometricGuard.guardAsyncAction<String>(
///   context: context,
///   reason: 'Authenticate to view sensitive data',
///   action: () async {
///     return await fetchSensitiveData();
///   },
/// );
///
/// // Confirmation with biometric:
/// final confirmed = await BiometricGuard.confirmWithBiometric(
///   context: context,
///   title: 'Delete Account',
///   message: 'Are you sure you want to delete your account?',
///   biometricReason: 'Authenticate to confirm deletion',
/// );
