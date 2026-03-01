import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
// import 'package:shimmer/shimmer.dart';
import '../../providers/profile_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/capsule/sound_capsule_screen.dart';
import '../../models/profile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      drawer: _buildDrawer(context, ref, profileAsync),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283A2C), Colors.black], // Dark green to black
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 8, 24),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // IconButton(
                      //   visualDensity: VisualDensity.compact,
                      //   icon: const Icon(Icons.bolt_outlined, size: 26),
                      //   onPressed: () {},
                      // ),
                      // IconButton(
                      //   visualDensity: VisualDensity.compact,
                      //   icon: const Icon(Icons.history, size: 26),
                      //   onPressed: () {},
                      // ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.search, size: 26),
                        onPressed: () {
                          context.push('/search');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: Row(
              //       children: [
              //         _buildChip('All', isSelected: true),
              //         const SizedBox(width: 8),
              //         _buildChip('Music'),
              //         const SizedBox(width: 8),
              //         _buildChip('Podcasts'),
              //       ],
              //     ),
              //   ),
              // ),
              // const SliverToBoxAdapter(child: SizedBox(height: 16)),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Your Playlists',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              playlistsAsync.when(
                data: (playlists) => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.75,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/playlist/${playlist.id}');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[900],
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
                                    ? const Center(
                                        child: Icon(
                                          Icons.music_note,
                                          size: 40,
                                          color: Colors.white54,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              playlist.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              playlist.ownerName ?? 'Spotify',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }, childCount: playlists.length),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error loading playlists: $error'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Jump back in Section
              // const SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 16.0,
              //       vertical: 8.0,
              //     ),
              //     child: Text(
              //       'Jump back in',
              //       style: TextStyle(
              //         fontSize: 22,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),

              // SliverToBoxAdapter(
              //   child: SizedBox(
              //     height: 200, // Fixed height for horizontal list
              //     child: playlistsAsync.when(
              //       data: (playlists) => ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         padding: const EdgeInsets.symmetric(horizontal: 16),
              //         itemCount: playlists.length > 5 ? 5 : playlists.length,
              //         itemBuilder: (context, index) {
              //           final playlist = playlists[index];
              //           return GestureDetector(
              //             onTap: () {
              //               context.push('/playlist/${playlist.id}');
              //             },
              //             child: Container(
              //               width: 140,
              //               margin: const EdgeInsets.only(right: 16),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Container(
              //                     width: 140,
              //                     height: 140,
              //                     decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.circular(8),
              //                       color: Colors.grey[900],
              //                       image: playlist.coverUrl != null
              //                           ? DecorationImage(
              //                               image: CachedNetworkImageProvider(
              //                                 playlist.coverUrl!,
              //                               ),
              //                               fit: BoxFit.cover,
              //                             )
              //                           : null,
              //                     ),
              //                     child: playlist.coverUrl == null
              //                         ? const Center(
              //                             child: Icon(
              //                               Icons.music_note,
              //                               size: 40,
              //                               color: Colors.white54,
              //                             ),
              //                           )
              //                         : null,
              //                   ),
              //                   const SizedBox(height: 8),
              //                   Text(
              //                     playlist.name,
              //                     style: const TextStyle(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                       fontSize: 14,
              //                     ),
              //                     maxLines: 1,
              //                     overflow: TextOverflow.ellipsis,
              //                   ),
              //                   Text(
              //                     playlist.ownerName ?? 'Spotify',
              //                     style: const TextStyle(
              //                       color: Colors.white54,
              //                       fontSize: 12,
              //                     ),
              //                     maxLines: 1,
              //                     overflow: TextOverflow.ellipsis,
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //       loading: () =>
              //           const Center(child: CircularProgressIndicator()),
              //       error: (error, stack) =>
              //           const Center(child: Text('Error loading')),
              //     ),
              //   ),
              // ),
              // const SliverToBoxAdapter(
              //   child: SizedBox(height: 24),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildChip(String label, {bool isSelected = false}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: isSelected ? const Color(0xFF1DB954) : Colors.white24,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       label,
  //       style: TextStyle(
  //         color: isSelected ? Colors.black : Colors.white,
  //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Profile> profileAsync,
  ) {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: profileAsync.when(
                data: (profile) => Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      backgroundImage: profile.profileImageUrl != null
                          ? CachedNetworkImageProvider(profile.profileImageUrl!)
                          : null,
                      child: profile.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName ?? 'Spotify User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'View profile',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => const SizedBox(),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(Icons.add, 'Add account', onTap: () {}),
                  _buildDrawerItem(Icons.bolt, "What's new", onTap: () {}),
                  _buildDrawerItem(
                    Icons.bar_chart,
                    'Your Sound Capsule',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SoundCapsuleScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(Icons.history, 'Recents', onTap: () {}),
                  _buildDrawerItem(
                    Icons.campaign_outlined,
                    'Your Updates',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    Icons.settings_outlined,
                    'Settings and privacy',
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
