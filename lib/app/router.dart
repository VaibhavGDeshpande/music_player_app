import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/search/search_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/details/playlist_screen.dart';
import '../screens/details/album_screen.dart';
import '../widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';

      final isAuthenticated = authState.value ?? false;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToSplash = state.uri.path == '/splash';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && (isGoingToLogin || isGoingToSplash)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/playlist/:id',
            builder: (context, state) =>
                PlaylistScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/album/:id',
            builder: (context, state) =>
                AlbumScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Center(child: Text('Error: ${state.error}')),
  );
});
