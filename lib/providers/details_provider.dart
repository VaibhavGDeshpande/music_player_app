import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart'; // defines spotifyServiceProvider

final playlistDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
      final service = ref.watch(spotifyServiceProvider);
      return await service.getPlaylist(id);
    });

final albumDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
      final service = ref.watch(spotifyServiceProvider);
      return await service.getAlbum(id);
    });
