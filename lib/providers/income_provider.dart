import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/income_source.dart';
import '../data/models/income_change_log.dart';
import '../data/repositories/income_source_repository.dart';

final incomeProvider =
    StateNotifierProvider<IncomeNotifier, List<IncomeSource>>((ref) {
      return IncomeNotifier();
    });

class IncomeNotifier extends StateNotifier<List<IncomeSource>> {
  final IncomeSourceRepository _repo = IncomeSourceRepository();

  IncomeNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAllIncomeSources();
  }

  Future<void> addSource(IncomeSource source) async {
    await _repo.addIncomeSource(source);
    _load();
  }

  Future<void> updateSource(IncomeSource source) async {
    await _repo.updateIncomeSource(source);
    _load();
  }

  Future<void> updateSourceNominal(
    String id,
    double newAmount,
    String? reason,
  ) async {
    final source = state.firstWhere((s) => s.id == id);

    if (source.amount != newAmount) {
      source.changeLog.add(
        IncomeChangeLog(
          oldAmount: source.amount,
          newAmount: newAmount,
          changedAt: DateTime.now(),
          reason: reason,
        ),
      );
      source.amount = newAmount;
      await _repo.updateIncomeSource(source);
      _load();
    }
  }

  Future<void> archiveSource(String id) async {
    final source = state.firstWhere((s) => s.id == id);
    source.isActive = false;
    source.deactivatedAt = DateTime.now();
    await _repo.updateIncomeSource(source);
    _load();
  }

  Future<void> deleteSourceCompletely(String id) async {
    await _repo.deleteIncomeSource(id);
    _load();
  }
}
