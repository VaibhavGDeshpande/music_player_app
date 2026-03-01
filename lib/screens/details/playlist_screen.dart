import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/details_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/track.dart';

class PlaylistScreen extends ConsumerWidget {
  final String id;

  const PlaylistScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailsProvider(id));
    final libraryAsync = ref.watch(libraryProvider);
    final downloadedTracks = libraryAsync.asData?.value ?? <Track>[];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: playlistAsync.when(
        data: (data) {
          final playlist = data['playlist'];
          final tracks = data['tracks'] as List;

          // debugPrint("Tracks length: ${tracks.length}");

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred background
                      if (playlist.coverUrl != null)
                        Image(
                          image: CachedNetworkImageProvider(playlist.coverUrl!),
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              const Color(0xFF121212),
                            ],
                          ),
                        ),
                      ),
                      // Playlist Cover
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          margin: const EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: playlist.coverUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      playlist.coverUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: playlist.coverUrl == null
                              ? const Icon(
                                  Icons.music_note,
                                  size: 80,
                                  color: Colors.white54,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Info row
                      Row(
                        children: [
                          if (playlist.ownerName != null) ...[
                            Text(
                              playlist.ownerName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                          Text(
                            '\${playlist.totalTracks} songs',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white54,
                            size: 28,
                          ),
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.download_for_offline_outlined,
                            color: Colors.white54,
                            size: 28,
                          ),
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                            size: 28,
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.shuffle,
                            color: Color(0xFF1DB954),
                            size: 28,
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              if (tracks.isNotEmpty) {
                                ref
                                    .read(playerProvider.notifier)
                                    .playQueue(
                                      tracks.cast<Track>(),
                                      initialIndex: 0,
                                    );
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1DB954),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Tracks List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final track = tracks[index];
                  final isDownloaded = downloadedTracks.any(
                    (t) => t.id == track.id,
                  );
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: track.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: track.coverUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
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
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artist,
                      style: const TextStyle(color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isDownloaded
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1DB954),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.download_for_offline_outlined,
                              color: Colors.white54,
                            ),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Downloading ${track.title}...',
                                  ),
                                  backgroundColor: const Color(0xFF1DB954),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              try {
                                await ref
                                    .read(libraryServiceProvider)
                                    .downloadSong(track.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${track.title} downloaded!',
                                      ),
                                      backgroundColor: const Color(0xFF1DB954),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  ref.invalidate(libraryProvider);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error downloading ${track.title}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                    onTap: () {
                      ref
                          .read(playerProvider.notifier)
                          .playQueue(tracks.cast<Track>(), initialIndex: index);
                    },
                  );
                }, childCount: tracks.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading playlist: $error',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
