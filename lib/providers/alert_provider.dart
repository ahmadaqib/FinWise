import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../data/repositories/user_profile_repository.dart';
import '../data/repositories/alert_repository.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';

final alertRuleProvider = Provider<AlertRuleEngine>((ref) {
  return AlertRuleEngine(ref);
});

class AlertRuleEngine {
  final Ref _ref;
  final NotificationService _notifService = NotificationService();
  final AlertRepository _repo = AlertRepository();

  AlertRuleEngine(this._ref);

  bool _isRuleEnabled(String id) {
    return _repo.getConfig(id).isEnabled;
  }

  void runChecks() {
    _checkBudget70();
    _checkBudget90();
    _checkDailyLimitExceeded();
    _checkInstallmentDeadline();
  }

  void _checkBudget70() {
    if (!_isRuleEnabled('budget_70')) return;
    final expense = _ref.read(totalExpenseThisMonthProvider);
    final freeBudget = _ref.read(freeBudgetProvider);
    if (freeBudget <= 0) return;

    final ratio = expense / freeBudget;
    if (ratio >= 0.7 && ratio < 0.9) {
      _notifService.showNotification(
        id: 1,
        title: '⚠️ Peringatan Anggaran (70%)',
        body:
            'Pengeluaran Anda sudah mencapai 70% dari batas aman bulan ini. Yuk mulai ngerem!',
      );
    }
  }

  void _checkBudget90() {
    if (!_isRuleEnabled('budget_90')) return;
    final expense = _ref.read(totalExpenseThisMonthProvider);
    final freeBudget = _ref.read(freeBudgetProvider);
    if (freeBudget <= 0) return;

    final ratio = expense / freeBudget;
    if (ratio >= 0.9) {
      _notifService.showNotification(
        id: 2,
        title: '🚨 Bahaya Anggaran (90%)',
        body:
            'DOMPET KERING! Pengeluaran sudah 90%. Stop pengeluaran non-esensial sekarang.',
      );
    }
  }

  void _checkDailyLimitExceeded() {
    if (!_isRuleEnabled('daily_limit')) return;
    final dailyLimit = _ref.read(dailySafeLimitProvider);
    final transactions = _ref.read(transactionProvider);
    final now = DateTime.now();

    final todayExpense = transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (todayExpense > dailyLimit) {
      _notifService.showNotification(
        id: 3,
        title: '📉 Limit Harian Terlampaui',
        body:
            'Anda telah melewati batas aman pengeluaran harian. Cobalah berhemat besok.',
      );
    }
  }

  void _checkInstallmentDeadline() {
    if (!_isRuleEnabled('cicilan_deadline')) return;
    final profile = UserProfileRepository().getProfile();
    if (profile == null) return;

    final dueDay = profile.cicilanDueDay;
    final now = DateTime.now();

    // Create a target date for the due date this month
    int targetMonth = now.month;
    int targetYear = now.year;

    // Handling edge case if due day doesn't exist in the current month (e.g., Feb 30th)
    int maxDaysThisMonth = DateTime(now.year, now.month + 1, 0).day;
    int actualDueDay = dueDay > maxDaysThisMonth ? maxDaysThisMonth : dueDay;

    DateTime dueDate = DateTime(targetYear, targetMonth, actualDueDay);

    // If due date has already passed this month, ignore
    if (now.isAfter(dueDate.add(const Duration(days: 1)))) return;

    final difference = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference == 3) {
      _notifService.showNotification(
        id: 4,
        title: '🗓️ H-3 Tagihan Cicilan',
        body:
            'Jangan lupa siapkan dana untuk cicilan 3 hari lagi. Tetap disiplin!',
      );
    } else if (difference == 1) {
      _notifService.showNotification(
        id: 5,
        title: '⚠️ Besok Jatuh Tempo!',
        body:
            'Cicilan bulan ini jatuh tempo besok. Pastikan dana sudah siap sebelum ditarik.',
      );
    } else if (difference == 0) {
      _notifService.showNotification(
        id: 6,
        title: '🚨 HARI INI JATUH TEMPO',
        body:
            'Halo! Cicilan bulan ini jatuh tempo hari ini. Segera lunasi agar tak kena denda.',
      );
    }
  }
}
