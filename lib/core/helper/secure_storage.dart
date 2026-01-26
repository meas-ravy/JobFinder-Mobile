import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:job_finder/core/helper/jwt_token.dart';
import 'package:job_finder/core/helper/typedef.dart';

enum TokensStorageKeys {
  // Key for storing authentication tokens
  authToken('app_auth_token');

  /// Key name
  final String keyName;
  const TokensStorageKeys(this.keyName);
}

class TokenStorageImpl implements TokenStorage<AuthToken> {
  const TokenStorageImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<AuthToken?> read() async {
    final tokenJson = await _secureStorage.read(
      key: TokensStorageKeys.authToken.keyName,
    );
    if (tokenJson == null) return null;
    return AuthToken.fromJson(jsonDecode(tokenJson) as DataMap);
  }

  @override
  Future<void> write(AuthToken token) {
    return _secureStorage.write(
      key: TokensStorageKeys.authToken.keyName,
      value: jsonEncode(token.toJson()),
    );
  }

  @override
  Future<void> delete() async {
    for (final key in TokensStorageKeys.values) {
      await _secureStorage.delete(key: key.keyName);
    }
  }
}
