import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/library_service.dart';
import '../models/track.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

final libraryProvider = FutureProvider<List<Track>>((ref) async {
  final libraryService = ref.watch(libraryServiceProvider);
  return await libraryService.getDownloadedSongs();
});
