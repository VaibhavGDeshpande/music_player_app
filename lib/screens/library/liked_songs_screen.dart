import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';

class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Liked Songs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF281854),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(libraryProvider);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF281854), Color(0xFF121212)],
            stops: [0.0, 0.4],
          ),
        ),
        child: libraryAsync.when(
          data: (tracks) {
            if (tracks.isEmpty) {
              return const Center(
                child: Text(
                  'No downloaded songs found.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '${tracks.length} songs',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tracks.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      // Calculate duration from durationMs if available
                      String timeStr = '--:--';
                      if (track.durationMs != null) {
                        final totalSeconds = track.durationMs! ~/ 1000;
                        final minutes = totalSeconds ~/ 60;
                        final seconds = totalSeconds % 60;
                        timeStr =
                            '$minutes:${seconds.toString().padLeft(2, '0')}';
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: track.coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: track.coverUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.music_note,
                                          color: Colors.white54,
                                        ),
                                      ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                        title: Text(
                          track.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          track.artist,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.favorite,
                              color: Color(0xFF1DB954),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.more_vert,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () {
                          debugPrint(
                            '[UI] Tapped on track: ${track.title} (id: ${track.id})',
                          );
                          ref
                              .read(playerProvider.notifier)
                              .playQueue(tracks, initialIndex: index);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1DB954)),
          ),
          error: (error, stack) {
            debugPrint('[UI] Library error: $error');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading songs',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
