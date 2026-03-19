import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/emergency_fund.dart';
import '../data/repositories/emergency_fund_repository.dart';
import 'package:uuid/uuid.dart';
import 'user_profile_provider.dart';

final emergencyFundRepositoryProvider = Provider((ref) => EmergencyFundRepository());

final emergencyFundEntriesProvider = StateNotifierProvider<EmergencyFundNotifier, List<EmergencyFundEntry>>((ref) {
  final repo = ref.watch(emergencyFundRepositoryProvider);
  return EmergencyFundNotifier(repo);
});

class EmergencyFundNotifier extends StateNotifier<List<EmergencyFundEntry>> {
  final EmergencyFundRepository _repo;

  EmergencyFundNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> addEntry({
    required double amount,
    required String source,
    String? note,
  }) async {
    final entry = EmergencyFundEntry(
      id: const Uuid().v4(),
      amount: amount,
      source: source,
      date: DateTime.now(),
      note: note,
    );
    await _repo.addEntry(entry);
    state = _repo.getAll();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteEntry(id);
    state = _repo.getAll();
  }
}

final emergencyFundBalanceProvider = Provider<double>((ref) {
  final entries = ref.watch(emergencyFundEntriesProvider);
  return entries.fold(0.0, (sum, entry) => sum + entry.amount);
});

final emergencyFundTargetProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.emergencyFundTarget ?? 0.0;
});
