import 'package:dio/dio.dart';
import '../models/lyric_line.dart';

class LyricsService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.json,
    ),
  );

  Future<List<LyricLine>> getLyrics(String trackId) async {
    try {
      final response = await _dio.get(
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
