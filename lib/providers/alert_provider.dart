import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import 'budget_provider.dart';

final alertRuleProvider = Provider<AlertRuleEngine>((ref) {
  return AlertRuleEngine(ref);
});

class AlertRuleEngine {
  final Ref _ref;
  final NotificationService _notifService = NotificationService();

  AlertRuleEngine(this._ref);

  void runChecks() {
    _checkBudget70();
    _checkBudget90();
    _checkDailyLimitExceeded();
  }

  void _checkBudget70() {
    final expense = _ref.watch(totalExpenseThisMonthProvider);
    final freeBudget = _ref.watch(freeBudgetProvider);
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
    final expense = _ref.watch(totalExpenseThisMonthProvider);
    final freeBudget = _ref.watch(freeBudgetProvider);
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
    // Logic for tracking if today's expenses > daily safe limit.
    // In a full implementation, we'd pull just today's transactions.
  }
}
