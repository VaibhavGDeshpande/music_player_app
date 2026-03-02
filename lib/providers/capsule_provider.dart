import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capsule_stats.dart';
import '../services/capsule_service.dart';

final capsuleServiceProvider = Provider<CapsuleService>((ref) {
  return CapsuleService();
});

final availableCapsuleMonthsProvider =
    FutureProvider.autoDispose<List<CapsuleMonth>>((ref) async {
      final service = ref.watch(capsuleServiceProvider);
      return await service.getAvailableMonths();
    });

class SelectedCapsuleMonthNotifier extends Notifier<CapsuleMonth?> {
  @override
  CapsuleMonth? build() => null;

  void select(CapsuleMonth? month) {
    state = month;
  }
}

final selectedCapsuleMonthProvider =
    NotifierProvider.autoDispose<SelectedCapsuleMonthNotifier, CapsuleMonth?>(
      SelectedCapsuleMonthNotifier.new,
    );

final capsuleStatsProvider = FutureProvider.autoDispose<CapsuleStats>((
  ref,
) async {
  final service = ref.watch(capsuleServiceProvider);
  final selectedMonth = ref.watch(selectedCapsuleMonthProvider);

  if (selectedMonth != null) {
    return await service.getCapsuleStats(
      month: selectedMonth.month,
      year: selectedMonth.year,
    );
  }

  try {
    final months = await ref.watch(availableCapsuleMonthsProvider.future);
    if (months.isNotEmpty) {
      return await service.getCapsuleStats(
        month: months.first.month,
        year: months.first.year,
      );
    }
  } catch (_) {
    // Fall back to server default month when month list fails.
  }

  return await service.getCapsuleStats();
});
