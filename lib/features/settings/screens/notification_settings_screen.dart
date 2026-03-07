import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/alert_config.dart';
import '../../../data/repositories/alert_repository.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _repo = AlertRepository();

  @override
  void initState() {
    super.initState();
  }

  AlertConfig _getConfig(String ruleId, double threshold) {
    return _repo.getConfig(ruleId, threshold: threshold);
  }

  Future<void> _toggleConfig(
    String ruleId,
    double threshold,
    bool value,
  ) async {
    final config = _getConfig(ruleId, threshold);
    config.isEnabled = value;
    await _repo.saveConfig(config);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi & Peringatan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Anggaran Bulanan'),
          _buildToggleTile(
            'budget_70',
            0.7,
            'Peringatan 70% Budget',
            'Beri tahu jika pengeluaran mencapai 70% limit.',
            LucideIcons.alertTriangle,
          ),
          _buildToggleTile(
            'budget_90',
            0.9,
            'Peringatan 90% Budget',
            'Beri tahu jika pengeluaran mencapai 90% limit.',
            LucideIcons.alertOctagon,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Harian & Cicilan'),
          _buildToggleTile(
            'daily_limit',
            1.0,
            'Batas Aman Harian',
            'Beri tahu jika pengeluaran hari ini melebihi batas.',
            LucideIcons.gauge,
          ),
          _buildToggleTile(
            'cicilan_deadline',
            0.0,
            'Pengingat Cicilan',
            'Peringatan saat mendekati jatuh tempo (H-3, H-1, H-0).',
            LucideIcons.calendarClock,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String id,
    double threshold,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final config = _getConfig(id, threshold);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: config.isEnabled,
        onChanged: (val) => _toggleConfig(id, threshold, val),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primaryMuted,
      ),
    );
  }
}
