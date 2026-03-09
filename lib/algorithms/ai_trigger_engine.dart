import 'package:uuid/uuid.dart';
import '../data/models/ai_context_package.dart';
import '../data/models/ai_insight.dart';

class AiTriggerEngine {
  final AIContextPackage context;

  AiTriggerEngine(this.context);

  List<AiInsight> generateInsights() {
    final insights = <AiInsight>[];

    // 1. Velocity Warning
    if (context.spendingVelocity > 1.2) {
      insights.add(
        AiInsight(
          id: const Uuid().v4(),
          title: '🔴 Laju Belanja Tinggi',
          content:
              'Kamu belanja ${((context.spendingVelocity - 1) * 100).toInt()}% lebih cepat dari biasanya. Hati-hati budget bisa habis sebelum akhir bulan.',
          type: 'warning',
          createdAt: DateTime.now(),
          actionLabel: 'Lihat Detail FLOW',
        ),
      );
    }

    // 2. Zone Anomaly (FREE zone exhausted early)
    final freeSpent = context.zoneDistribution['free'] ?? 0;
    final freeBudget = context.freeBudget * 0.1; // Default 10% for FREE zone
    if (freeSpent > freeBudget && context.adaptiveDailySafeLimit > 0) {
      insights.add(
        AiInsight(
          id: const Uuid().v4(),
          title: '⚠️ Zone FREE Menipis',
          content:
              'Jatah "jajan" kamu bulan ini sudah hampir habis. Fokus ke Zone FLOW saja ya untuk sisa hari ini.',
          type: 'tip',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 3. Freedom Index Milestone
    if (context.freedomIndex > 50) {
      insights.add(
        AiInsight(
          id: const Uuid().v4(),
          title: '🚀 Milestone Tercapai!',
          content:
              'Freedom Index kamu sudah di atas 50%. Separuh biaya hidupmu sudah bisa ditutup oleh income non-aktif!',
          type: 'achievement',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 4. Low FWS Warning
    if (context.currentFWS < 200) {
      insights.add(
        AiInsight(
          id: const Uuid().v4(),
          title: '🚨 Keuangan Fragile',
          content:
              'Skor FWS kamu sedang sangat rendah. Prioritaskan pembangunan dana darurat segera.',
          type: 'warning',
          createdAt: DateTime.now(),
          actionLabel: 'Benahi Fundamen',
        ),
      );
    }

    return insights;
  }
}
