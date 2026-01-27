import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';

enum TokensStorageKeys {
  // Key for storing authentication tokens
  accessToken('app_access_token'),
  role('app_user_role');

  /// Key name
  final String keyName;
  const TokensStorageKeys(this.keyName);
}

class TokenStorageImpl implements TokenStorage<String> {
  const TokenStorageImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> read() async {
    final token = await _secureStorage.read(
      key: TokensStorageKeys.accessToken.keyName,
    );
    if (token == null || token.isEmpty) return null;
    return token;
  }

  @override
  Future<void> write(String token) {
    return _secureStorage.write(
      key: TokensStorageKeys.accessToken.keyName,
      value: token,
    );
  }

  @override
  Future<void> delete() async {
    for (final key in TokensStorageKeys.values) {
      await _secureStorage.delete(key: key.keyName);
    }
  }

  Future<String?> readRole() async {
    final role = await _secureStorage.read(key: TokensStorageKeys.role.keyName);
    if (role == null || role.isEmpty) return null;
    return role;
  }

  Future<void> writeRole(String role) {
    return _secureStorage.write(
      key: TokensStorageKeys.role.keyName,
      value: role,
    );
  }

  Future<void> deleteRole() {
    return _secureStorage.delete(key: TokensStorageKeys.role.keyName);
  }
}
