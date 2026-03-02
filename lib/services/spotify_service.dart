import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/profile.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../models/search_results.dart';

class SpotifyService {
  final Dio _dio = ApiClient.dio;
  Profile? _cachedProfile;
  Future<Profile>? _profileInFlight;

  // Cache for local storage paths to avoid redundant API calls during search/navigation
  Map<String, String>? _cachedLocalPaths;
  DateTime? _lastLocalPathsFetch;
  Future<Map<String, String>>? _localPathsInFlight;
  List<Playlist>? _cachedPlaylists;
  Future<List<Playlist>>? _playlistsInFlight;
  DateTime? _lastPlaylistsFetch;
  static const Duration _localPathsCacheTtl = Duration(minutes: 5);
  static const Duration _playlistsCacheTtl = Duration(minutes: 1);

  Future<Profile> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;
    if (_profileInFlight != null) return _profileInFlight!;

    final request = _dio.get('/api/me').then((response) {
      _cachedProfile = Profile.fromJson(response.data);
      return _cachedProfile!;
    });

    _profileInFlight = request;
    debugPrint('[SPOTIFY] Fetching profile from /api/me...');
    try {
      return await request;
    } finally {
      _profileInFlight = null;
    }
  }

  Future<Map<String, String>> _getLocalPaths({
    bool forceRefresh = false,
  }) async {
    // If we have a recent cache (e.g., within the last 5 minutes), return it
    if (!forceRefresh &&
        _cachedLocalPaths != null &&
        _lastLocalPathsFetch != null &&
        DateTime.now().difference(_lastLocalPathsFetch!) <
            _localPathsCacheTtl) {
      return _cachedLocalPaths!;
    }

    if (!forceRefresh && _localPathsInFlight != null) {
      return _localPathsInFlight!;
    }

    final request = _refreshLocalPaths();
    _localPathsInFlight = request;
    try {
      return await request;
    } finally {
      _localPathsInFlight = null;
    }
  }

  Future<Map<String, String>> _refreshLocalPaths() async {
    final Map<String, String> paths = {};

    Future<void> fetchAndParse(String endpoint) async {
      try {
        final response = await _dio.get(endpoint);
        final List<dynamic> items = response.data is List
            ? response.data
            : (response.data is Map
                  ? (response.data['songs'] ?? response.data['items'] ?? [])
                  : []);

        for (var item in items) {
          final data = item is Map && item.containsKey('track')
              ? item['track']
              : item;
          final sid = (data['spotify_id'] ?? data['id'] ?? '').toString();
          if (sid.isNotEmpty &&
              data['storage_path'] != null &&
              data['storage_path'] != "null") {
            paths[sid] = data['storage_path'].toString();
          }
        }
      } catch (e) {
        debugPrint('[SPOTIFY] Error fetching from $endpoint: $e');
      }
    }

    debugPrint('[SPOTIFY] Refreshing local paths cache...');
    // Fetch from both sources: explicitly downloaded songs and liked songs from DB
    await Future.wait([
      fetchAndParse('/api/my-songs'),
      fetchAndParse('/api/user-liked-songs'),
    ]);

    _cachedLocalPaths = paths;
    _lastLocalPathsFetch = DateTime.now();
    return paths;
  }

  Future<List<Playlist>> getPlaylists() async {
    if (_cachedPlaylists != null &&
        _lastPlaylistsFetch != null &&
        DateTime.now().difference(_lastPlaylistsFetch!) < _playlistsCacheTtl) {
      return _cachedPlaylists!;
    }
    if (_playlistsInFlight != null) return _playlistsInFlight!;

    final request = _fetchPlaylists();
    _playlistsInFlight = request;
    try {
      return await request;
    } finally {
      _playlistsInFlight = null;
    }
  }

  Future<List<Playlist>> _fetchPlaylists() async {
    debugPrint('[SPOTIFY] Fetching playlists from /api/playlists...');
    final response = await _dio.get('/api/playlists');

    List<dynamic> data;
    if (response.data is List) {
      data = response.data;
    } else if (response.data['items'] != null) {
      data = response.data['items'];
    } else {
      data = [];
    }

    _cachedPlaylists = data.map((json) => Playlist.fromJson(json)).toList();
    _lastPlaylistsFetch = DateTime.now();
    return _cachedPlaylists!;
  }

  Future<SearchResults> search(String query) async {
    final responseFuture = _dio.get(
      '/api/search',
      queryParameters: {'q': query},
    );
    final localPathsFuture = _getLocalPaths();
    final response = await responseFuture;
    final localPaths = await localPathsFuture;
    final data = response.data;

    // Parse tracks
    List<Track> tracks = [];
    if (data['tracks'] != null && data['tracks']['items'] != null) {
      for (var item in data['tracks']['items']) {
        final trackJson = Map<String, dynamic>.from(item);
        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '')
            .toString();
        if (localPaths.containsKey(tid)) {
          trackJson['storage_path'] = localPaths[tid];
        }
        tracks.add(Track.fromJson(trackJson));
      }
    }

    // Parse artists/albums
    List<SpotifyArtist> artists = (data['artists']?['items'] as List? ?? [])
        .map((json) => SpotifyArtist.fromJson(json))
        .toList();
    List<SpotifyAlbum> albums = (data['albums']?['items'] as List? ?? [])
        .map((json) => SpotifyAlbum.fromJson(json))
        .toList();

    return SearchResults(tracks: tracks, artists: artists, albums: albums);
  }

  Future<Map<String, dynamic>> getPlaylist(String id) async {
    final localPathsFuture = _getLocalPaths();
    final response = await _dio.get('/api/playlists/$id');
    final data = response.data;

    final playlist = Playlist.fromJson(data);
    List<Track> tracks = [];
    final localPaths = await localPathsFuture;

    List<dynamic>? rawItems =
        data['tracks']?['items'] ?? data['items']?['items'];

    if (rawItems != null) {
      for (var entry in rawItems) {
        final trackJson = Map<String, dynamic>.from(
          entry['track'] ?? entry['item'] ?? entry,
        );
        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '')
            .toString();
        if (localPaths.containsKey(tid)) {
          trackJson['storage_path'] = localPaths[tid];
        }
        tracks.add(Track.fromJson(trackJson));
      }
    }

    return {'playlist': playlist, 'tracks': tracks};
  }

  Future<Map<String, dynamic>> getAlbum(String id) async {
    final localPathsFuture = _getLocalPaths();
    final response = await _dio.get('/api/albums/$id');
    final data = response.data;

    final album = SpotifyAlbum.fromJson(data);
    List<Track> tracks = [];
    final localPaths = await localPathsFuture;

    if (data['tracks'] != null && data['tracks']['items'] != null) {
      for (var item in data['tracks']['items']) {
        final trackJson = Map<String, dynamic>.from(item);
        if (trackJson['album'] == null) trackJson['album'] = data;

        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '')
            .toString();
        if (localPaths.containsKey(tid)) {
          trackJson['storage_path'] = localPaths[tid];
        }
        tracks.add(Track.fromJson(trackJson));
      }
    }

    return {'album': album, 'tracks': tracks};
  }

  // Method to manually clear cache if needed (e.g., after a new download)
  void invalidateLocalCache() {
    _cachedLocalPaths = null;
    _lastLocalPathsFetch = null;
    _cachedPlaylists = null;
    _lastPlaylistsFetch = null;
    _cachedProfile = null;
  }
}
