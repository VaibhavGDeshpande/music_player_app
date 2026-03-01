import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<bool> checkAuthStatus() async {
    final cookie = await SecureStorage.getSession();
    if (cookie == null || cookie.isEmpty) {
      return false;
    }

    try {
      final response = await _dio.get('/api/me');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await SecureStorage.deleteSession();
    }
  }

  Future<void> saveSessionCookie(String cookie) async {
    await SecureStorage.saveSession(cookie);
  }
}
