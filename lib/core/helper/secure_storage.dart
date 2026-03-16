import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Keys used for storing data in secure storage
enum SecureStorageKey {
  accessToken('app_access_token'),
  role('app_user_role'),
  hasSeenOnboarding('has_seen_onboarding'),
  locale('app_locale'),
  biometricEnabled('biometric_enabled'),
  appPin('app_pin'),
  appLockEnabled('app_lock_enabled'),
  securityQuestion('security_question'),
  securityAnswer('security_answer'),
  firebaseToken('firebase_token'),
  isPremium('is_premium'),
  cvHealthScore('cv_health_score');

  final String keyName;
  const SecureStorageKey(this.keyName);
}

// A service to provide type-safe access to stored data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  // Writes a value to secure storage
  Future<void> write(SecureStorageKey key, String value) async {
    await _storage.write(key: key.keyName, value: value);
  }

  // Reads a value from secure storage
  Future<String?> read(SecureStorageKey key) async {
    return await _storage.read(key: key.keyName);
  }

  // Deletes a value from secure storage
  Future<void> delete(SecureStorageKey key) async {
    await _storage.delete(key: key.keyName);
  }

  // Deletes all values from secure storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

// Provider 
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});

/// Implementation of [TokenStorage] using [SecureStorageService]
class TokenStorageImpl implements TokenStorage<String> {
  const TokenStorageImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  /// Internal getter to use the [SecureStorageService] wrapper
  SecureStorageService get _service => SecureStorageService(_secureStorage);

  @override
  Future<String?> read() async {
    final token = await _service.read(SecureStorageKey.accessToken);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  @override
  Future<void> write(String token) {
    return _service.write(SecureStorageKey.accessToken, token);
  }

  @override
  Future<void> delete() async {
    // clear authentication related data on logout/unauthorized
    await _service.delete(SecureStorageKey.accessToken);
    await _service.delete(SecureStorageKey.role);
    await _service.delete(SecureStorageKey.firebaseToken);
  }

  /// Reads the user role from storage
  Future<String?> readRole() async {
    final role = await _service.read(SecureStorageKey.role);
    if (role == null || role.isEmpty) return null;
    return role;
  }

  /// Writes the user role to storage
  Future<void> writeRole(String role) {
    return _service.write(SecureStorageKey.role, role);
  }

  /// Deletes the user role from storage
  Future<void> deleteRole() {
    return _service.delete(SecureStorageKey.role);
  }

  /// Checks if the user has seen the onboarding screen
  Future<bool> readHasSeenOnboarding() async {
    final value = await _service.read(SecureStorageKey.hasSeenOnboarding);
    return value == 'true';
  }

  /// Sets the onboarding screen as seen
  Future<void> writeHasSeenOnboarding() {
    return _service.write(SecureStorageKey.hasSeenOnboarding, 'true');
  }

  /// Reads the Firebase token from storage
  Future<String?> readFirebaseToken() async {
    return await _service.read(SecureStorageKey.firebaseToken);
  }

  /// Writes the Firebase token to storage
  Future<void> writeFirebaseToken(String token) {
    return _service.write(SecureStorageKey.firebaseToken, token);
  }

  /// Deletes the Firebase token from storage
  Future<void> deleteFirebaseToken() {
    return _service.delete(SecureStorageKey.firebaseToken);
  }
}

/// Provider for the [TokenStorageImpl]
final tokenStorageProvider = Provider<TokenStorageImpl>((ref) {
  return const TokenStorageImpl(FlutterSecureStorage());
});
