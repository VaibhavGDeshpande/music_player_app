import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lyrics_provider.dart';
import '../../providers/player_provider.dart';

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine(int currentIndex, int totalLines) {
    if (!_scrollController.hasClients || currentIndex < 0) return;

    // Estimate 60 pixels per line item
    final position =
        (currentIndex * 60.0) - (MediaQuery.of(context).size.height / 3);

    _scrollController.animateTo(
      position.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(currentLyricsProvider);
    final playerState = ref.watch(playerProvider);
    final currentMs = playerState.position.inMilliseconds;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6A1B9A), // Deep purple background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Lyrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: lyricsAsync.when(
              data: (lines) {
                if (lines.isEmpty) {
                  return const Center(
                    child: Text(
                      'No lyrics available',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  );
                }

                // Find current line index
                int currentIndex =
                    lines.indexWhere((line) => line.startTimeMs > currentMs) -
                    1;
                if (currentIndex == -2) currentIndex = lines.length - 1;
                if (currentIndex < 0) currentIndex = 0;

                // Auto-scroll side effect
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _scrollToCurrentLine(currentIndex, lines.length);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 3,
                    horizontal: 24,
                  ),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    final isCurrent = index == currentIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: isCurrent ? 28 : 24,
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w600,
                          height: 1.3,
                        ),
                        child: Text(line.words),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(
                child: Text(
                  'Failed to load lyrics',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
