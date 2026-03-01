class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final int? durationMs;
  final String? storagePath;
  final String? previewUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.durationMs,
    this.storagePath,
    this.previewUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    // Attempt extracting artist from different possible Spotify formats
    String artistStr = 'Unknown Artist';
    if (json['artist'] != null && json['artist'] is String) {
      artistStr = json['artist'];
    } else if (json['artists'] != null &&
        (json['artists'] as List).isNotEmpty) {
      artistStr = (json['artists'] as List)
          .map((a) => a['name'] as String)
          .join(', ');
    }

    // Extract album name
    String? albumStr = json['album'] is String ? json['album'] : null;
    if (json['album'] != null &&
        json['album'] is Map &&
        json['album']['name'] != null) {
      albumStr = json['album']['name'];
    }

    // Extract cover image
    String? cover = json['cover_url'];
    if (cover == null &&
        json['album'] != null &&
        json['album']['images'] != null &&
        (json['album']['images'] as List).isNotEmpty) {
      cover = json['album']['images'][0]['url'];
    }

    return Track(
      id: (json['id'] ?? json['spotify_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Unknown Song').toString(),
      artist: artistStr,
      album: albumStr,
      coverUrl: cover,
      durationMs: json['duration_ms'] as int?,
      storagePath: json['storage_path'] as String?,
      previewUrl: json['preview_url'] as String?,
    );
  }
}
