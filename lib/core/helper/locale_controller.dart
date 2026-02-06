import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleController extends ValueNotifier<Locale?> {
  static const String _storageKey = 'app_locale';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LocaleController() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _storage.read(key: _storageKey);
    if (languageCode != null) {
      value = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (value == locale) return;
    value = locale;
    await _storage.write(key: _storageKey, value: locale.languageCode);
  }

  Future<void> clearLocale() async {
    value = null;
    await _storage.delete(key: _storageKey);
  }
}

final LocaleController localeController = LocaleController();
