import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import 'profile_provider.dart';

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final spotifyService = ref.watch(spotifyServiceProvider);
  return await spotifyService.getPlaylists();
});
