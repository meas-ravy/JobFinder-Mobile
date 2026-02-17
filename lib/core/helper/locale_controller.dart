import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';

class LocaleController extends ValueNotifier<Locale?> {
  final SecureStorageService _storage = const SecureStorageService(
    FlutterSecureStorage(),
  );

  LocaleController() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _storage.read(SecureStorageKey.locale);
    if (languageCode != null) {
      value = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (value == locale) return;
    value = locale;
    await _storage.write(SecureStorageKey.locale, locale.languageCode);
  }

  Future<void> clearLocale() async {
    value = null;
    await _storage.delete(SecureStorageKey.locale);
  }
}

final LocaleController localeController = LocaleController();
