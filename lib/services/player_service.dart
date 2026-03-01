import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../core/network/api_client.dart';
import '../models/track.dart';
import '../config/env.dart';

class PlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = ApiClient.dio;

  Track? _currentTrack;
  StreamSubscription<Duration>? _positionSubscription;
  int _cumulativeListenedMs = 0;
  int _lastPositionMs = 0;

  PlayerService() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_currentTrack != null && _audioPlayer.playing) {
        int currentMs = position.inMilliseconds;
        // If the position moved forward typically (not a huge seek jump)
        // We accumulate the delta difference
        int delta = currentMs - _lastPositionMs;

        // Arbitrary threshold: if delta is positive and less than 2 seconds, it's normal playback tick
        if (delta > 0 && delta < 2000) {
          _cumulativeListenedMs += delta;
        }

        _lastPositionMs = currentMs;
      }
    });

    // Reset last position if we seek or jump around
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState != ProcessingState.ready) {
        _lastPositionMs = _audioPlayer.position.inMilliseconds;
      }
    });
  }

  Future<void> _logPlayback(Track track, int listenedMs) async {
    // Only log if listened for at least 1 second (1000ms is the backend minimum)
    if (listenedMs < 1000) return;

    try {
      debugPrint(
        '[PLAYER] Logging playback for: ${track.title} (listened: ${listenedMs}ms)',
      );
      await _dio.post(
        '/api/player/log',
        data: {
          'trackId': track.id,
          'trackName': track.title,
          'artistName': track.artist,
          'albumName': track.album,
          'imageUrl': track.coverUrl,
          'durationMs': track.durationMs,
          'listenedMs': listenedMs,
        },
      );
    } catch (e) {
      debugPrint('[PLAYER] Analytics log failed: $e');
    }
  }

  AudioPlayer get player => _audioPlayer;

  /// Constructs the public Supabase Storage URL for a given storage path.
  String _buildStorageUrl(String storagePath) {
    final cleanPath = storagePath.startsWith('/')
        ? storagePath.substring(1)
        : storagePath;
    return '${Env.supabaseUrl}/storage/v1/object/public/music/$cleanPath';
  }

  Future<void> playTrack(Track track) async {
    // If there's an existing track playing/paused, log its total listened time
    if (_currentTrack != null && _cumulativeListenedMs >= 1000) {
      _logPlayback(_currentTrack!, _cumulativeListenedMs);
    }

    _currentTrack = track;
    _cumulativeListenedMs = 0;
    _lastPositionMs = 0;

    try {
      String? audioUrl;

      debugPrint('========== [PLAYER] PLAY TRACK ==========');
      debugPrint('[PLAYER] Track: ${track.title} by ${track.artist}');
      debugPrint('[PLAYER] Track ID: ${track.id}');
      debugPrint('[PLAYER] storagePath: "${track.storagePath}"');
      debugPrint('[PLAYER] previewUrl: "${track.previewUrl}"');

      // Attempt to get the playable URL if storagePath/previewUrl are missing
      if ((track.storagePath == null ||
              track.storagePath!.isEmpty ||
              track.storagePath == "null") &&
          (track.previewUrl == null ||
              track.previewUrl!.isEmpty ||
              track.previewUrl == "null")) {
        debugPrint(
          '[PLAYER] No path/preview. Fetching stream URL from /api/stream...',
        );
        try {
          // Check if this track is in our local DB to get its storagePath
          final response = await _dio.get('/api/stream/${track.id}');
          if (response.data != null && response.data['storage_path'] != null) {
            audioUrl = _buildStorageUrl(response.data['storage_path']);
            debugPrint('[PLAYER] Resolved from /api/stream: $audioUrl');
          }
        } catch (e) {
          debugPrint('[PLAYER] /api/stream failed: $e');
        }
      }

      // If we still don't have a URL, try the track metadata endpoint (backup)
      if (audioUrl == null &&
          (track.storagePath == null ||
              track.storagePath!.isEmpty ||
              track.storagePath == "null") &&
          (track.previewUrl == null ||
              track.previewUrl!.isEmpty ||
              track.previewUrl == "null")) {
        debugPrint('[PLAYER] Trying /api/tracks/${track.id}...');
        try {
          final response = await _dio.get('/api/tracks/${track.id}');
          if (response.data != null) {
            final updatedTrack = Track.fromJson(response.data);
            if (updatedTrack.storagePath != null &&
                updatedTrack.storagePath != "null") {
              audioUrl = _buildStorageUrl(updatedTrack.storagePath!);
              debugPrint('[PLAYER] Resolved from /api/tracks: $audioUrl');
            }
          }
        } catch (e) {
          debugPrint('[PLAYER] /api/tracks failed: $e');
        }
      }

      // Fallback to build URL from current track if we have info
      if (audioUrl == null) {
        if (track.storagePath != null &&
            track.storagePath!.isNotEmpty &&
            track.storagePath != "null") {
          if (track.storagePath!.startsWith('http')) {
            audioUrl = track.storagePath;
          } else {
            audioUrl = _buildStorageUrl(track.storagePath!);
          }
        } else if (track.previewUrl != null &&
            track.previewUrl!.isNotEmpty &&
            track.previewUrl != "null") {
          audioUrl = track.previewUrl;
        }
      }

      if (audioUrl == null) {
        debugPrint('[PLAYER] ERROR: No audio source found!');
        await _audioPlayer.pause();
        throw Exception("No playable audio source for '${track.title}'.");
      }

      debugPrint('[PLAYER] URL: $audioUrl');
      debugPrint('[PLAYER] Sending to ExoPlayer...');
      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
      debugPrint('[PLAYER] Playback started successfully!');
    } catch (e) {
      debugPrint('[PLAYER] Error playing track: $e');
      await _audioPlayer.pause();
      rethrow;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  void dispose() {
    // Log the last track on dispose
    if (_currentTrack != null && _cumulativeListenedMs >= 1000) {
      _logPlayback(_currentTrack!, _cumulativeListenedMs);
    }
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
  }
}
