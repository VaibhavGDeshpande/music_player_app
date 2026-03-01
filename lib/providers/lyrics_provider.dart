import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lyric_line.dart';
import '../services/lyrics_service.dart';
import 'player_provider.dart';

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

final currentLyricsProvider = FutureProvider<List<LyricLine>>((ref) async {
  final playerState = ref.watch(playerProvider);
  final trackId = playerState.currentTrack?.id;

  if (trackId == null || trackId.isEmpty) {
    return [];
  }

  final lyricsService = ref.watch(lyricsServiceProvider);
  return await lyricsService.getLyrics(trackId);
});
