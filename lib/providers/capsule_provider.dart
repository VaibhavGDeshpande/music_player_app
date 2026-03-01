import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capsule_stats.dart';
import '../services/capsule_service.dart';

final capsuleServiceProvider = Provider<CapsuleService>((ref) {
  return CapsuleService();
});

final capsuleStatsProvider = FutureProvider.autoDispose<CapsuleStats>((
  ref,
) async {
  final service = ref.watch(capsuleServiceProvider);
  return await service.getCapsuleStats();
});
