import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_results.dart';
import 'profile_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return SearchResults.empty();

  final spotifyService = ref.watch(spotifyServiceProvider);
  return await spotifyService.search(query);
});
