import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/capsule_stats.dart';
import '../../providers/capsule_provider.dart';

class SoundCapsuleScreen extends ConsumerWidget {
  const SoundCapsuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsuleAsync = ref.watch(capsuleStatsProvider);
    final monthsAsync = ref.watch(availableCapsuleMonthsProvider);
    final selectedMonth = ref.watch(selectedCapsuleMonthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Your Sound Capsule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: capsuleAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MonthSelector(
                      monthsAsync: monthsAsync,
                      selectedMonth: selectedMonth,
                      onChanged: (month) {
                        ref
                            .read(selectedCapsuleMonthProvider.notifier)
                            .select(month);
                      },
                    ),
                    const Icon(Icons.share, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 24),

                // Time Listened Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Time listened',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white54),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              '${stats.timeListenedMinutes}',
                              style: const TextStyle(
                                color: Color(0xFF1DB954),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'min',
                            style: TextStyle(
                              color: Color(0xFF1DB954),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Top Artist & Top Song Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Top artist',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats.topArtistName,
                              style: const TextStyle(
                                color: Color(0xFF4A90E2), // Blue
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[900],
                                    backgroundImage:
                                        stats.topArtistImage.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            stats.topArtistImage,
                                          )
                                        : null,
                                    child: stats.topArtistImage.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white54,
                                            size: 40,
                                          )
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'New',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Top song',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats.topSongName,
                              style: const TextStyle(
                                color: Color(0xFFFFD700), // Yellow
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(4),
                                      image: stats.topSongImage.isNotEmpty
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                stats.topSongImage,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: stats.topSongImage.isEmpty
                                        ? const Icon(
                                            Icons.music_note,
                                            color: Colors.white54,
                                            size: 40,
                                          )
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'New',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom Group Image Card
                // if (stats.recentCovers.isNotEmpty)
                //   Container(
                //     width: double.infinity,
                //     height: 200,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF2A2A2A),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     clipBehavior: Clip.antiAlias,
                //     child: Stack(
                //       children: [
                //         // We do a funky grid layout to mimic the group shot
                //         GridView.builder(
                //           physics: const NeverScrollableScrollPhysics(),
                //           gridDelegate:
                //               const SliverGridDelegateWithFixedCrossAxisCount(
                //                 crossAxisCount: 3,
                //                 childAspectRatio: 1,
                //               ),
                //           itemCount: stats.recentCovers.length,
                //           itemBuilder: (context, index) {
                //             return CachedNetworkImage(
                //               imageUrl: stats.recentCovers[index],
                //               fit: BoxFit.cover,
                //             );
                //           },
                //         ),
                //         // Dark overlay over the grid
                //         Container(color: Colors.black.withValues(alpha: 0.5)),
                //       ],
                //     ),
                //   )
                // else
                //   Container(
                //     width: double.infinity,
                //     height: 200,
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF2A2A2A),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // const SizedBox(height: 32),

                // Top Tracks List
                if (stats.topTracks.isNotEmpty) ...[
                  const Text(
                    'Your Top Tracks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...stats.topTracks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final track = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: track.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: track.image,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white54,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  track.artist,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${track.count}',
                                style: const TextStyle(
                                  color: Color(0xFF1DB954),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'plays',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 120), // Miniplayer padding
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading capsule data',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.monthsAsync,
    required this.selectedMonth,
    required this.onChanged,
  });

  final AsyncValue<List<CapsuleMonth>> monthsAsync;
  final CapsuleMonth? selectedMonth;
  final ValueChanged<CapsuleMonth?> onChanged;

  @override
  Widget build(BuildContext context) {
    return monthsAsync.when(
      data: (months) {
        if (months.isEmpty) {
          return const Text(
            'Current Month',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        final current = selectedMonth ?? months.first;

        return DropdownButtonHideUnderline(
          child: DropdownButton<CapsuleMonth>(
            value: months.contains(current) ? current : months.first,
            dropdownColor: const Color(0xFF2A2A2A),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            items: months
                .map(
                  (month) => DropdownMenuItem<CapsuleMonth>(
                    value: month,
                    child: Text(
                      month.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        );
      },
      loading: () => const SizedBox(
        height: 28,
        width: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF1DB954),
        ),
      ),
      error: (_, _) => const Text(
        'Current Month',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
