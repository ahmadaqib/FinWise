import 'package:flutter/material.dart';
import '../../../../shared/widgets/health_gauge.dart';

class HealthScoreSection extends StatelessWidget {
  final int score;

  const HealthScoreSection({super.key, required this.score});

  String _getScoreLabel(int score) {
    if (score >= 75) return 'Keuangan Sehat';
    if (score >= 50) return 'Perlu Perhatian';
    return 'Kondisi Bahaya';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HealthGauge(score: score, label: _getScoreLabel(score)),
    );
  }
}
