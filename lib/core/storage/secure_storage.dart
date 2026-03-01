import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'session_cookie';

  static Future<void> saveSession(String cookie) async {
    await _storage.write(key: _sessionKey, value: cookie);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: _sessionKey);
  }

  static Future<void> deleteSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
