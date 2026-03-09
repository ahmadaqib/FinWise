import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/monthly_summary.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/monthly_summary_repository.dart';
import '../providers/budget_provider.dart';
import '../providers/user_profile_provider.dart';

final monthlySummaryRepositoryProvider = Provider(
  (ref) => MonthlySummaryRepository(),
);

final archiveServiceProvider = Provider((ref) => ArchiveService(ref));

class ArchiveService {
  final Ref _ref;
  ArchiveService(this._ref);

  Future<void> checkAndArchive() async {
    final profile = _ref.read(userProfileProvider);
    if (profile == null) return;

    final salaryDate = profile.salaryDate;
    final now = DateTime.now();

    // Get the range for the cycle that just presumably ended
    // If today is gajian (now.day == salaryDate), we check if the PREVIOUS cycle was archived.
    DateTime cycleStart;
    if (now.day >= salaryDate) {
      // Current cycle started today or recently this month.
      // The cycle to archive ended yesterday.
      cycleStart = DateTime(now.year, now.month - 1, salaryDate);
    } else {
      // We are still in the cycle that started last month.
      // The cycle to archive ended two months ago? No, that doesn't make sense.
      // Archiving usually happens on the day of salary.
      return;
    }

    // Check if we already archived this month's cycle
    if (profile.lastArchivedDate != null) {
      if (profile.lastArchivedDate!.year == cycleStart.year &&
          profile.lastArchivedDate!.month == cycleStart.month) {
        return; // Already archived
      }
    }

    await _performArchive(profile, cycleStart);
  }

  Future<void> _performArchive(UserProfile profile, DateTime cycleStart) async {
    final repo = _ref.read(monthlySummaryRepositoryProvider);
    await repo.init();

    // We need to calculate the summary for the cycle that JUST ENDED.
    // This is tricky because providers currently point to the CURRENT cycle.
    // For now, let's just archive the state as it was just before the reset.
    // A more robust way would be to query transactions for that specific range.

    final income = _ref.read(totalFixedIncomeProvider);
    final expense = _ref.read(totalExpenseThisMonthProvider);
    final saldo = _ref.read(remainingBudgetProvider);
    final score = _ref.read(finWiseScoreProvider).compute();
    final spending = _ref.read(zoneSpendingProvider);

    final summary = MonthlySummary(
      month: cycleStart.month,
      year: cycleStart.year,
      totalIncome: income,
      totalExpense: expense,
      saldo: saldo,
      fwsScore: score,
      zoneShieldSpent: spending['shield'],
      zoneFlowSpent: spending['flow'],
      zoneGrowSpent: spending['grow'],
      zoneFreeSpent: spending['free'],
      startDate: cycleStart,
      endDate: DateTime(
        cycleStart.year,
        cycleStart.month + 1,
        profile.salaryDate - 1,
        23,
        59,
        59,
      ),
    );

    await repo.saveSummary(summary);

    // Update profile
    profile.lastArchivedDate = DateTime.now();
    await profile.save();
  }
}
