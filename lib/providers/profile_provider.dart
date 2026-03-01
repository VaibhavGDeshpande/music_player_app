import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spotify_service.dart';
import '../models/profile.dart';

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  return SpotifyService();
});

final profileProvider = FutureProvider<Profile>((ref) async {
  final spotifyService = ref.watch(spotifyServiceProvider);
  return await spotifyService.getProfile();
});
