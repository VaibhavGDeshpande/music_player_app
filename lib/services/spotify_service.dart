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
  
  // Cache for local storage paths to avoid redundant API calls during search/navigation
  Map<String, String>? _cachedLocalPaths;
  DateTime? _lastLocalPathsFetch;

  Future<Profile> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;
    debugPrint('[SPOTIFY] Fetching profile from /api/me...');
    final response = await _dio.get('/api/me');
    _cachedProfile = Profile.fromJson(response.data);
    return _cachedProfile!;
  }

  Future<Map<String, String>> _getLocalPaths({bool forceRefresh = false}) async {
    // If we have a recent cache (e.g., within the last 5 minutes), return it
    if (!forceRefresh && 
        _cachedLocalPaths != null && 
        _lastLocalPathsFetch != null && 
        DateTime.now().difference(_lastLocalPathsFetch!) < const Duration(minutes: 5)) {
      return _cachedLocalPaths!;
    }

    final Map<String, String> paths = {};
    
    Future<void> fetchAndParse(String endpoint) async {
      try {
        final response = await _dio.get(endpoint);
        final List<dynamic> items = response.data is List 
            ? response.data 
            : (response.data is Map ? (response.data['songs'] ?? response.data['items'] ?? []) : []);
        
        for (var item in items) {
          final data = item is Map && item.containsKey('track') ? item['track'] : item;
          final sid = (data['spotify_id'] ?? data['id'] ?? '').toString();
          if (sid.isNotEmpty && data['storage_path'] != null && data['storage_path'] != "null") {
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

    return data.map((json) => Playlist.fromJson(json)).toList();
  }

  Future<SearchResults> search(String query) async {
    final response = await _dio.get(
      '/api/search',
      queryParameters: {'q': query},
    );

    final data = response.data;
    final localPaths = await _getLocalPaths();

    // Parse tracks
    List<Track> tracks = [];
    if (data['tracks'] != null && data['tracks']['items'] != null) {
      for (var item in data['tracks']['items']) {
        final trackJson = Map<String, dynamic>.from(item);
        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '').toString();
        if (localPaths.containsKey(tid)) {
          trackJson['storage_path'] = localPaths[tid];
        }
        tracks.add(Track.fromJson(trackJson));
      }
    }

    // Parse artists/albums
    List<SpotifyArtist> artists = (data['artists']?['items'] as List? ?? [])
        .map((json) => SpotifyArtist.fromJson(json)).toList();
    List<SpotifyAlbum> albums = (data['albums']?['items'] as List? ?? [])
        .map((json) => SpotifyAlbum.fromJson(json)).toList();

    return SearchResults(tracks: tracks, artists: artists, albums: albums);
  }

  Future<Map<String, dynamic>> getPlaylist(String id) async {
    final response = await _dio.get('/api/playlists/$id');
    final data = response.data;

    final playlist = Playlist.fromJson(data);
    List<Track> tracks = [];
    final localPaths = await _getLocalPaths();

    List<dynamic>? rawItems = data['tracks']?['items'] ?? data['items']?['items'];

    if (rawItems != null) {
      for (var entry in rawItems) {
        final trackJson = Map<String, dynamic>.from(entry['track'] ?? entry['item'] ?? entry);
        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '').toString();
        if (localPaths.containsKey(tid)) {
          trackJson['storage_path'] = localPaths[tid];
        }
        tracks.add(Track.fromJson(trackJson));
      }
    }

    return {'playlist': playlist, 'tracks': tracks};
  }

  Future<Map<String, dynamic>> getAlbum(String id) async {
    final response = await _dio.get('/api/albums/$id');
    final data = response.data;

    final album = SpotifyAlbum.fromJson(data);
    List<Track> tracks = [];
    final localPaths = await _getLocalPaths();

    if (data['tracks'] != null && data['tracks']['items'] != null) {
      for (var item in data['tracks']['items']) {
        final trackJson = Map<String, dynamic>.from(item);
        if (trackJson['album'] == null) trackJson['album'] = data;
        
        final tid = (trackJson['id'] ?? trackJson['spotify_id'] ?? '').toString();
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
  }
}
