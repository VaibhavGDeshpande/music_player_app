import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';

import '../../widgets/player/lyrics_view.dart';

class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  bool _showLyrics = false;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final track = playerState.currentTrack;

    if (track == null) {
      return const Scaffold(
        body: Center(child: Text('No track is currently playing')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showLyrics ? Icons.lyrics : Icons.lyrics_outlined),
            color: _showLyrics ? const Color(0xFF1DB954) : Colors.white,
            onPressed: () {
              setState(() {
                _showLyrics = !_showLyrics;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[800]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Album Art
                        Hero(
                          tag: 'album_art_${track.id}',
                          child: Container(
                            width: MediaQuery.of(context).size.width - 48,
                            height: MediaQuery.of(context).size.width - 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              image: track.coverUrl != null
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        track.coverUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: track.coverUrl == null
                                ? const Icon(
                                    Icons.music_note,
                                    size: 100,
                                    color: Colors.white24,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Track Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.artist,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border, size: 28),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Progress Bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            trackShape: const RectangularSliderTrackShape(),
                          ),
                          child: Slider(
                            min: 0,
                            max:
                                playerState.duration.inMilliseconds.toDouble() >
                                    0
                                ? playerState.duration.inMilliseconds.toDouble()
                                : 1.0,
                            value: playerState.position.inMilliseconds
                                .toDouble()
                                .clamp(
                                  0.0,
                                  playerState.duration.inMilliseconds
                                              .toDouble() >
                                          0
                                      ? playerState.duration.inMilliseconds
                                            .toDouble()
                                      : 1.0,
                                ),
                            onChanged: (value) {
                              ref
                                  .read(playerProvider.notifier)
                                  .seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),

                        // Timestamps
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(playerState.position),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _formatDuration(playerState.duration),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shuffle, size: 24),
                              color: Colors.white54,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_previous, size: 40),
                              color: playerState.queue.isNotEmpty
                                  ? Colors.white
                                  : Colors.white54,
                              onPressed: () {
                                ref
                                    .read(playerProvider.notifier)
                                    .skipPrevious();
                              },
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: playerState.isBuffering
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Icon(
                                        playerState.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 36,
                                        color: Colors.black,
                                      ),
                                onPressed: () {
                                  if (playerState.isPlaying) {
                                    ref.read(playerProvider.notifier).pause();
                                  } else {
                                    ref.read(playerProvider.notifier).resume();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next, size: 40),
                              color: playerState.queue.isNotEmpty
                                  ? Colors.white
                                  : Colors.white54,
                              onPressed: () {
                                ref.read(playerProvider.notifier).skipNext();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                playerState.isLooping
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                                size: 24,
                              ),
                              color: playerState.isLooping
                                  ? const Color(0xFF1DB954)
                                  : Colors.white54,
                              onPressed: () {
                                ref.read(playerProvider.notifier).toggleLoop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomSheet: _showLyrics
          ? LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: double.infinity,
                  child: const LyricsView(),
                );
              },
            )
          : null,
    );
  }
}
