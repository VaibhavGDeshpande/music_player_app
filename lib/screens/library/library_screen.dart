import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/library_provider.dart';
import '../../screens/library/liked_songs_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final playlistsAsync = ref.watch(playlistsProvider);
    final likedSongsAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF121212),
              pinned: true,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  profileAsync.when(
                    data: (profile) => GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: profileAsync.when(
                            data: (profile) => CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  profile.profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      profile.profileImageUrl!,
                                    )
                                  : null,
                              child: profile.profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            loading: () => const CircleAvatar(radius: 18),
                            error: (error, stack) =>
                                const CircleAvatar(radius: 18),
                          ),
                        ),
                    loading: () => const CircleAvatar(radius: 16),
                    error: (e, s) => const CircleAvatar(radius: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.search, color: Colors.white, size: 28),
              //     onPressed: () {},
              //   ),
              //   IconButton(
              //     icon: const Icon(Icons.add, color: Colors.white, size: 28),
              //     onPressed: () {},
              //   ),
              //   const SizedBox(width: 8),
              // ],
            ),

            // Filter Chips
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16.0,
            //       vertical: 8.0,
            //     ),
            //     child: Row(
            //       children: [
            //         _buildChip('Playlists'),
            //         const SizedBox(width: 8),
            //         _buildChip('Albums'),
            //       ],
            //     ),
            //   ),
            // ),

            // Sorting Row
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: const [
            //             Icon(Icons.swap_vert, color: Colors.white, size: 20),
            //             SizedBox(width: 8),
            //             Text(
            //               'Recents',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const Icon(Icons.grid_view, color: Colors.white, size: 20),
            //       ],
            //     ),
            //   ),
            // ),

            // Liked Songs Static Tile
            SliverToBoxAdapter(
              child: likedSongsAsync.when(
                data: (tracks) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4B39EF), Color(0xFFA1F0D4)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    'Liked Songs',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.push_pin,
                        color: Color(0xFF1DB954),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Playlist • ${tracks.length} songs',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LikedSongsScreen(),
                      ),
                    );
                  },
                ),
                loading: () => const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text(
                    'Liked Songs',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                error: (e, s) => const ListTile(
                  title: Text(
                    'Liked Songs',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text('Error loading count'),
                ),
              ),
            ),

            // Dynamic Playlists list
            playlistsAsync.when(
              data: (playlists) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(4),
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
                              color: Colors.white54,
                              size: 32,
                            )
                          : null,
                    ),
                    title: Text(
                      playlist.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Playlist • ${playlist.ownerName ?? 'Spotify'}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.push('/playlist/${playlist.id}');
                    },
                  );
                }, childCount: playlists.length),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'Error loading: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildChip(String label) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white24,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       label,
  //       style: const TextStyle(color: Colors.white, fontSize: 13),
  //     ),
  //   );
  // }
}
