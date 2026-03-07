import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../income_sources/screens/income_sources_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileRepository().getProfile();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryMuted,
                child: Icon(LucideIcons.user, color: AppColors.primary),
              ),
              title: Text(
                profile?.name ?? 'Profil Anda',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Atur profil & gaji'),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsGroup('Keuangan'),
          _buildListTile(context, LucideIcons.wallet, 'Sumber Pendapatan', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IncomeSourcesScreen()),
            );
          }),
          _buildListTile(
            context,
            LucideIcons.bell,
            'Notifikasi & Peringatan',
            () {},
          ),
          _buildListTile(context, LucideIcons.bot, 'Gemini AI Advisor', () {}),
          const SizedBox(height: 24),
          _buildSettingsGroup('Sistem'),
          _buildListTile(
            context,
            LucideIcons.download,
            'Ekspor Data CSV',
            () {},
          ),
          _buildListTile(
            context,
            LucideIcons.trash2,
            'Hapus Semua Data',
            () {},
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.danger : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 16,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
