import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/track.dart';
import '../../models/search_results.dart';
import '../../providers/search_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _textController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).updateQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final libraryAsync = ref.watch(libraryProvider);
    final downloadedTracks = libraryAsync.asData?.value ?? <Track>[];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'What do you want to listen to?',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              _textController.clear();
                              ref
                                  .read(searchQueryProvider.notifier)
                                  .updateQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: searchResultsAsync.when(
                data: (results) {
                  if (ref.read(searchQueryProvider).isEmpty) {
                    return _buildBrowseAllGrid();
                  } else if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // --- Top Result (first artist if available) ---
                      if (results.artists.isNotEmpty) ...[
                        const _SectionTitle(title: 'Top Result'),
                        const SizedBox(height: 12),
                        _buildTopResultCard(results.artists.first),
                        const SizedBox(height: 24),
                      ],

                      // --- Songs ---
                      if (results.tracks.isNotEmpty) ...[
                        const _SectionTitle(title: 'Songs'),
                        const SizedBox(height: 8),
                        ...results.tracks.map(
                          (track) => _buildTrackTile(track, downloadedTracks),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // --- Artists ---
                      if (results.artists.length > 1) ...[
                        const _SectionTitle(title: 'Artists'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: results.artists.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) =>
                                _buildArtistCard(results.artists[index]),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // --- Albums ---
                      if (results.albums.isNotEmpty) ...[
                        const _SectionTitle(title: 'Albums'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: results.albums.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) =>
                                _buildAlbumCard(results.albums[index]),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Top Result Card =====================
  Widget _buildTopResultCard(SpotifyArtist artist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: artist.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: artist.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Artist',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Track Tile =====================
  Widget _buildTrackTile(Track track, List<Track> downloadedTracks) {
    final isDownloaded = downloadedTracks.any((t) => t.id == track.id);

    return InkWell(
      onTap: () {
        ref.read(playerProvider.notifier).playTrack(track);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: track.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: track.coverUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[800],
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${track.artist}${track.album != null ? ' • ${track.album}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
            isDownloaded
                ? const Icon(Icons.check_circle, color: Color(0xFF1DB954))
                : IconButton(
                    icon: const Icon(
                      Icons.download_for_offline_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading ${track.title}...'),
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
                              content: Text('${track.title} downloaded!'),
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
                              content: Text('Error downloading ${track.title}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // ===================== Artist Card =====================
  Widget _buildArtistCard(SpotifyArtist artist) {
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(65),
            child: artist.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: artist.imageUrl!,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 130,
                    height: 130,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Artist',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ===================== Album Card =====================
  Widget _buildAlbumCard(SpotifyAlbum album) {
    return GestureDetector(
      onTap: () {
        context.push('/album/${album.id}');
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: album.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: album.imageUrl!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.album,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              album.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Browse All Grid =====================
  Widget _buildBrowseAllGrid() {
    final genres = [
      {'title': 'Pop', 'color': const Color(0xFFE13300)},
      {'title': 'Hip-Hop', 'color': const Color(0xFF1E3264)},
      {'title': 'Rock', 'color': const Color(0xFFE91429)},
      {'title': 'Latin', 'color': const Color(0xFFE1118C)},
      {'title': 'Dance/Electronic', 'color': const Color(0xFF509BF5)},
      {'title': 'R&B', 'color': const Color(0xFFDC148C)},
      {'title': 'Indie', 'color': const Color(0xFF608108)},
      {'title': 'Workout', 'color': const Color(0xFF777777)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse all',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return GestureDetector(
                  onTap: () {
                    final query = genre['title'] as String;
                    _textController.text = query;
                    ref.read(searchQueryProvider.notifier).updateQuery(query);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: genre['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      genre['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Section Title Widget =====================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
