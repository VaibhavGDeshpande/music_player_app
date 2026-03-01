class CapsuleTrack {
  final int count;
  final String name;
  final String artist;
  final String image;
  final String id;

  CapsuleTrack({
    required this.count,
    required this.name,
    required this.artist,
    required this.image,
    required this.id,
  });

  factory CapsuleTrack.fromJson(Map<String, dynamic> json) {
    return CapsuleTrack(
      count: json['count'] ?? 0,
      name: json['name'] ?? 'Unknown Track',
      artist: json['artist'] ?? 'Unknown Artist',
      image: json['image'] ?? '',
      id: json['id'] ?? '',
    );
  }
}

class CapsuleStats {
  final int totalPlays;
  final List<CapsuleTrack> topTracks;

  // Computed fields to keep existing UI working
  final int timeListenedMinutes;
  final String topArtistName;
  final String topArtistImage;
  final String topSongName;
  final String topSongImage;
  final List<String> recentCovers;

  CapsuleStats({
    required this.totalPlays,
    required this.topTracks,
    required this.timeListenedMinutes,
    required this.topArtistName,
    required this.topArtistImage,
    required this.topSongName,
    required this.topSongImage,
    required this.recentCovers,
  });

  factory CapsuleStats.fromJson(Map<String, dynamic> json) {
    List<CapsuleTrack> tracks = [];
    if (json['top_tracks'] != null) {
      tracks = (json['top_tracks'] as List)
          .map((item) => CapsuleTrack.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final totalPlays = json['total_plays'] ?? 0;

    // Calculate synthetic fields for existing UI elements
    // In a real scenario, the API would also return minutes listened and top artist separately
    final timeListenedMinutes = json['total_minutes']; // Estimate: 3 min per play

    String topSongName = tracks.isNotEmpty ? tracks.first.name : 'Unknown';
    String topSongImage = tracks.isNotEmpty ? tracks.first.image : '';
    String topArtistName = tracks.isNotEmpty ? tracks.first.artist : 'Unknown';
    String topArtistImage = topSongImage; // Fallback

    // Group images
    final recentCovers = tracks
        .map((t) => t.image)
        .where((url) => url.isNotEmpty)
        .take(6)
        .toList();

    return CapsuleStats(
      totalPlays: totalPlays,
      topTracks: tracks,
      timeListenedMinutes: timeListenedMinutes,
      topArtistName: topArtistName,
      topArtistImage: topArtistImage,
      topSongName: topSongName,
      topSongImage: topSongImage,
      recentCovers: recentCovers,
    );
  }

  factory CapsuleStats.empty() {
    return CapsuleStats(
      totalPlays: 0,
      topTracks: [],
      timeListenedMinutes: 0,
      topArtistName: 'Unknown',
      topArtistImage: '',
      topSongName: 'Unknown',
      topSongImage: '',
      recentCovers: [],
    );
  }
}
