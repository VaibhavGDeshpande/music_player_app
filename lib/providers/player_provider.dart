import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../services/player_service.dart';

final playerServiceProvider = Provider<PlayerService>((ref) {
  final service = PlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

class PlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;
  final List<Track> queue;
  final int currentIndex;
  final bool isLooping;

  PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
    this.queue = const [],
    this.currentIndex = -1,
    this.isLooping = false,
  });

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
    List<Track>? queue,
    int? currentIndex,
    bool? isLooping,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isLooping: isLooping ?? this.isLooping,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerState> {
  late final PlayerService _playerService = ref.read(playerServiceProvider);

  @override
  PlayerState build() {
    Future.microtask(_initListeners);
    return PlayerState();
  }

  void _initListeners() {
    _playerService.player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      state = state.copyWith(
        isPlaying: isPlaying,
        isBuffering:
            processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading,
      );

      if (processingState == ProcessingState.completed) {
        if (state.isLooping) {
          seek(Duration.zero);
          resume();
        } else {
          skipNext();
        }
      }
    });

    _playerService.player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _playerService.player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  Future<void> playTrack(Track track) async {
    try {
      debugPrint('[PLAYER_PROVIDER] Playing track: ${track.title}');

      // If queue is empty or doesn't contain this track, create a single item queue
      List<Track> newQueue = state.queue;
      int newIndex = state.currentIndex;

      if (newQueue.isEmpty ||
          !newQueue.where((t) => t.id == track.id).isNotEmpty) {
        newQueue = [track];
        newIndex = 0;
      } else {
        newIndex = newQueue.indexWhere((t) => t.id == track.id);
      }

      state = state.copyWith(
        currentTrack: track,
        position: Duration.zero,
        queue: newQueue,
        currentIndex: newIndex,
      );
      await _playerService.playTrack(track);
    } catch (e) {
      debugPrint('[PLAYER_PROVIDER] Error playing track: $e');
      state = state.copyWith(
        currentTrack: null,
        isPlaying: false,
        isBuffering: false,
      );
    }
  }

  Future<void> playQueue(List<Track> queue, {int initialIndex = 0}) async {
    if (queue.isEmpty) return;
    state = state.copyWith(queue: queue, currentIndex: initialIndex);
    await playTrack(queue[initialIndex]);
  }

  Future<void> skipNext() async {
    if (state.queue.isEmpty) return;
    int nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.queue.length) {
      nextIndex = 0; // Loop back to start by default
    }

    state = state.copyWith(currentIndex: nextIndex);
    await playTrack(state.queue[nextIndex]);
  }

  Future<void> skipPrevious() async {
    if (state.queue.isEmpty) return;
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    int prevIndex = state.currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = state.queue.length - 1;
    }

    state = state.copyWith(currentIndex: prevIndex);
    await playTrack(state.queue[prevIndex]);
  }

  void toggleLoop() {
    state = state.copyWith(isLooping: !state.isLooping);
  }

  Future<void> pause() async {
    await _playerService.pause();
  }

  Future<void> resume() async {
    await _playerService.resume();
  }

  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});
