import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _showWebView = false;
  InAppWebViewController? webViewController;
  CookieManager cookieManager = CookieManager.instance();

  void _startLogin() {
    setState(() {
      _showWebView = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Login with Spotify'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showWebView = false;
              });
            },
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('${AppConstants.apiBaseUrl}/api/auth/login'),
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            if (url != null && url.path.contains('/dashboard')) {
              // We successfully logged in and were redirected. Extract cookies.
              List<Cookie> cookies = await cookieManager.getCookies(url: url);
              String sessionCookieStr = '';
              for (var cookie in cookies) {
                if (cookie.name == 'session') {
                  sessionCookieStr = '${cookie.name}=${cookie.value}';
                  break;
                }
              }

              if (sessionCookieStr.isNotEmpty) {
                // Save session in provider
                await ref.read(authProvider.notifier).login(sessionCookieStr);
              } else {
                // Edge case: No session cookie found despite reaching dashboard.
                if (!context.mounted) return;
                String cookieNames = cookies.map((c) => c.name).join(', ');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to retrieve session cookie. Found: ${cookieNames.isEmpty ? "None" : cookieNames}',
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
                setState(() {
                  _showWebView = false;
                });
              }
            }
          },
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'MusicPlayer',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _startLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Login with Spotify',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref
                    .read(authProvider.notifier)
                    .login(
                      'session=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhNTY2NmI0My0yOTRmLTQ0OGEtYTU2NS05MTQ2NjA5YWQ0NDciLCJpYXQiOjE3NzIzNDExNTYsImV4cCI6MTc3Mjk0NTk1Nn0.Th90v_MZbGud7SBpEamWx5hGzpQ5BuZzxYf484BDt2Y',
                    );
              },
              child: const Text(
                'Dev: Use Temp Session',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
