import 'package:dio/dio.dart';
import '../models/lyric_line.dart';

class LyricsService {
  Future<List<LyricLine>> getLyrics(String trackId) async {
    try {
      // Create a fresh Dio instance to avoid the base URL interceptors from ApiClient
      final dio = Dio();
      final response = await dio.get(
        'https://spotify-lyrics-topaz.vercel.app/',
        queryParameters: {'trackid': trackId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> linesData = response.data['lines'] ?? [];
        return linesData.map((json) => LyricLine.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Return empty array on error (e.g., 404 No lyrics found)
      return [];
    }
  }
}
