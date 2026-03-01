import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends AsyncNotifier<bool> {
  late final AuthService _authService = ref.read(authServiceProvider);

  @override
  FutureOr<bool> build() async {
    return await _authService.checkAuthStatus();
  }

  Future<void> login(String cookie) async {
    state = const AsyncValue.loading();
    await _authService.saveSessionCookie(cookie);
    state = await AsyncValue.guard(() => _authService.checkAuthStatus());
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authService.logout();
    state = const AsyncValue.data(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
