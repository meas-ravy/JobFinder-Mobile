import 'package:flutter/material.dart';
import 'package:job_finder/core/services/biometric_service.dart';

/// Wrapper widget that requires biometric authentication before displaying child
class BiometricProtectedWidget extends StatefulWidget {
  const BiometricProtectedWidget({
    super.key,
    required this.child,
    this.reason = 'Authenticate to access this feature',
    this.onAuthenticationFailed,
  });

  final Widget child;
  final String reason;
  final VoidCallback? onAuthenticationFailed;

  @override
  State<BiometricProtectedWidget> createState() =>
      _BiometricProtectedWidgetState();
}

class _BiometricProtectedWidgetState extends State<BiometricProtectedWidget> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _checkAndAuthenticate();
  }

  Future<void> _checkAndAuthenticate() async {
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();

    if (!isBiometricEnabled) {
      // Biometric not enabled, allow access
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
      return;
    }

    // Biometric enabled, require authentication
    final authenticated = await _biometricService.authenticate(
      reason: widget.reason,
    );

    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
      });

      if (!authenticated) {
        widget.onAuthenticationFailed?.call();
      }
    }
  }

  Future<void> _retry() async {
    setState(() => _isAuthenticating = true);
    await _checkAndAuthenticate();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Required',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You need to authenticate to access this feature',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Authenticate'),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }
}

/// Helper function to wrap a route with biometric authentication
Future<T?> pushBiometricProtectedRoute<T>({
  required BuildContext context,
  required Widget child,
  String reason = 'Authenticate to access this feature',
  VoidCallback? onAuthenticationFailed,
}) {
  return Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (context) => BiometricProtectedWidget(
        reason: reason,
        onAuthenticationFailed: onAuthenticationFailed,
        child: child,
      ),
    ),
  );
}
