import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppStorageService {
  const AppStorageService._();

  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _privacyAcceptedKey = 'privacy_accepted';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>('app_cache');
  }

  static Future<void> saveToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  static Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await Hive.box<dynamic>('app_cache').clear();
  }

  static Future<bool> isPrivacyAccepted() async {
    final value = Hive.box<dynamic>('app_cache').get(_privacyAcceptedKey);
    return value == true;
  }

  static Future<void> setPrivacyAccepted(bool accepted) async {
    await Hive.box<dynamic>('app_cache').put(_privacyAcceptedKey, accepted);
  }
}
