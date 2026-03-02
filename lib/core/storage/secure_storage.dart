import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'session_cookie';
  static String? _cachedSession;
  static bool _hasHydratedCache = false;
  static Future<String?>? _sessionReadInFlight;

  static Future<void> saveSession(String cookie) async {
    await _storage.write(key: _sessionKey, value: cookie);
    _cachedSession = cookie;
    _hasHydratedCache = true;
  }

  static Future<String?> getSession() async {
    if (_hasHydratedCache) {
      return _cachedSession;
    }

    if (_sessionReadInFlight != null) {
      return _sessionReadInFlight;
    }

    final readFuture = _storage.read(key: _sessionKey);
    _sessionReadInFlight = readFuture;

    try {
      final value = await readFuture;
      _cachedSession = value;
      _hasHydratedCache = true;
      return value;
    } finally {
      _sessionReadInFlight = null;
    }
  }

  static Future<void> deleteSession() async {
    await _storage.delete(key: _sessionKey);
    _cachedSession = null;
    _hasHydratedCache = true;
  }
}
