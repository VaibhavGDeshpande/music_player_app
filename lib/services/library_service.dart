import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/track.dart';

class LibraryService {
  final Dio _dio = ApiClient.dio;

  Future<List<Track>> getDownloadedSongs() async {
    try {
      debugPrint('[LIBRARY] Fetching songs from /api/my-songs...');
      final response = await _dio.get('/api/my-songs');

      debugPrint('[LIBRARY] Response status: ${response.statusCode}');
      debugPrint('[LIBRARY] Response type: ${response.data.runtimeType}');

      // Print first item to see what fields are available
      if (response.data is List && (response.data as List).isNotEmpty) {
        debugPrint('[LIBRARY] First song data: ${response.data[0]}');
      } else if (response.data is Map && response.data['songs'] != null) {
        final songs = response.data['songs'] as List;
        if (songs.isNotEmpty) {
          debugPrint('[LIBRARY] First song data: ${songs[0]}');
        }
      }

      List<dynamic> items = [];
      if (response.data is List) {
        items = response.data;
      } else if (response.data['songs'] != null) {
        items = response.data['songs'];
      }

      debugPrint('[LIBRARY] Parsed ${items.length} songs');
      return items.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[LIBRARY] Error fetching songs: $e');
      return [];
    }
  }

  Future<void> downloadSong(String trackId) async {
    try {
      debugPrint('[LIBRARY] Downloading song: $trackId...');
      final response = await _dio.post(
        '/api/download',
        data: {'trackId': trackId},
      );
      debugPrint('[LIBRARY] Download complete: ${response.statusCode}');
    } catch (e) {
      debugPrint('[LIBRARY] Error downloading song: $e');
      rethrow;
    }
  }
}
