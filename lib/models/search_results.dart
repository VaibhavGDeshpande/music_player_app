import 'track.dart';

class SpotifyArtist {
  final String id;
  final String name;
  final String? imageUrl;

  SpotifyArtist({required this.id, required this.name, this.imageUrl});

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    String? image;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      image = json['images'][0]['url'];
    }
    return SpotifyArtist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Artist',
      imageUrl: image,
    );
  }
}

class SpotifyAlbum {
  final String id;
  final String name;
  final String? imageUrl;
  final String artist;
  final int totalTracks;

  SpotifyAlbum({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.artist,
    required this.totalTracks,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    String? image;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      image = json['images'][0]['url'];
    }

    String artist = 'Unknown Artist';
    if (json['artists'] != null && (json['artists'] as List).isNotEmpty) {
      artist = (json['artists'] as List)
          .map((a) => a['name'] as String)
          .join(', ');
    }

    return SpotifyAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Album',
      imageUrl: image,
      artist: artist,
      totalTracks: json['total_tracks'] ?? 0,
    );
  }
}

class SearchResults {
  final List<Track> tracks;
  final List<SpotifyArtist> artists;
  final List<SpotifyAlbum> albums;

  SearchResults({
    required this.tracks,
    required this.artists,
    required this.albums,
  });

  bool get isEmpty => tracks.isEmpty && artists.isEmpty && albums.isEmpty;

  factory SearchResults.empty() =>
      SearchResults(tracks: [], artists: [], albums: []);
}
