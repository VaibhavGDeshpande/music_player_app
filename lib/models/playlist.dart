class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? ownerName;
  final int totalTracks;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.ownerName,
    this.totalTracks = 0,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    // Extract image
    String? imageUrl = json['cover_url'] as String?;

    if (imageUrl == null &&
        json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'] as String?;
    }

    // Extract owner
    String? owner = json['owner_name'] as String?;

    if (owner == null &&
        json['owner'] != null &&
        json['owner'] is Map) {
      owner = json['owner']['display_name'] as String?;
    }

    // Extract total tracks
    int total = 0;

    // Case 1: direct total field
    if (json['total'] is int) {
      total = json['total'] as int;
    }

    // Case 2: Spotify official format
    if (total == 0 &&
        json['tracks'] != null &&
        json['tracks'] is Map) {
      total = (json['tracks']['total'] as int?) ?? 0;
    }

    // Case 3: Your API response (items.total)
    if (total == 0 &&
        json['items'] != null &&
        json['items'] is Map) {
      total = (json['items']['total'] as int?) ?? 0;
    }

    return Playlist(
      id: (json['id'] ?? json['spotify_id'] ?? '') as String,
      name: (json['name'] ?? 'Unknown Playlist') as String,
      description: json['description'] as String?,
      coverUrl: imageUrl,
      ownerName: owner,
      totalTracks: total,
    );
  }
}