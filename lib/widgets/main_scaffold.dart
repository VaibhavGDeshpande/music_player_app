import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'player/mini_player.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine the current index based on the route
    int currentIndex = 0;
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/search')) {
      currentIndex = 1;
    } else if (location.startsWith('/library')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/library');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
