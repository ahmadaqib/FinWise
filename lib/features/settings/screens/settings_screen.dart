import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../services/backup_service.dart';
import '../../../shared/widgets/flat_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../income_sources/screens/income_sources_screen.dart';
import '../../cicilan/screens/cicilan_list_screen.dart';
import 'notification_settings_screen.dart';
import 'gemini_settings_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileRepository().getProfile();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          _buildProfileCard(context, profile, isDark),
          const SizedBox(height: AppSpacing.xxl),

          const SectionHeader(title: 'Pengaturan Cicilan'),
          const SizedBox(height: AppSpacing.md),
          FlatCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _buildSettingTile(
              context: context,
              icon: LucideIcons.calendarClock,
              title: 'Kelola Cicilan',
              subtitle: 'KPR, Kendaraan, Pinjaman',
              iconBgColor: isDark ? AppColors.darkInfoBg : AppColors.infoBg,
              iconColor: isDark ? AppColors.primaryLight : AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CicilanListScreen()),
                );
              },
              isDark: isDark,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Keuangan'),
          const SizedBox(height: AppSpacing.md),
          FlatCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.wallet,
                  title: 'Sumber Pendapatan',
                  iconBgColor: isDark
                      ? AppColors.darkSuccessBg
                      : AppColors.successBg,
                  iconColor: isDark
                      ? const Color(0xFF6EDC98)
                      : AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncomeSourcesScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  height: 1,
                ),
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.bell,
                  title: 'Notifikasi & Peringatan',
                  iconBgColor: isDark
                      ? AppColors.darkWarningBg
                      : AppColors.warningBg,
                  iconColor: isDark
                      ? const Color(0xFFFCD34D)
                      : AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  height: 1,
                ),
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.bot,
                  title: 'Gemini AI Advisor',
                  iconBgColor: isDark
                      ? const Color(0xFFE0E7FF).withOpacity(0.1)
                      : const Color(0xFFE0E7FF),
                  iconColor: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF4F46E5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GeminiSettingsScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Sistem & Data'),
          const SizedBox(height: AppSpacing.md),
          FlatCard(
            padding: EdgeInsets.zero,
            backgroundColor: isDark
                ? AppColors.darkSubtle
                : AppColors.surfaceSubtle,
            child: Column(
              children: [
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.share2,
                  title: 'Ekspor Data (Backup)',
                  iconBgColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  iconColor: isDark
                      ? AppColors.textInverseSecondary
                      : AppColors.textSecondary,
                  onTap: () async {
                    try {
                      final file = await BackupService.exportDataToJson();
                      // Share the file
                      await Share.shareXFiles([
                        XFile(file.path),
                      ], subject: 'FinWise Backup ${DateTime.now().toLocal()}');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal backup: $e')),
                        );
                      }
                    }
                  },
                  isDark: isDark,
                ),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  height: 1,
                ),
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.upload,
                  title: 'Impor Data (Restore)',
                  iconBgColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  iconColor: isDark
                      ? AppColors.textInverseSecondary
                      : AppColors.textSecondary,
                  onTap: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );

                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        final content = await file.readAsString();

                        if (context.mounted) {
                          // Show confirmation dialog before overwriting
                          final confirmed =
                              await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Restore'),
                                  content: const Text(
                                    'Proses ini akan menghapus data saat ini dan menggantinya dengan data dari file backup. Lanjutkan?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                      ),
                                      child: const Text('Ya, Restore'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                          if (confirmed) {
                            await BackupService.importDataFromJson(content);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Restore berhasil! Silakan restart aplikasi.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal restore: $e')),
                        );
                      }
                    }
                  },
                  isDark: isDark,
                ),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  height: 1,
                ),
                _buildSettingTile(
                  context: context,
                  icon: LucideIcons.trash2,
                  title: 'Hapus Semua Data',
                  isDestructive: true,
                  iconBgColor: isDark
                      ? AppColors.darkDangerBg
                      : AppColors.dangerBg,
                  iconColor: isDark
                      ? const Color(0xFFFCA5A5)
                      : AppColors.danger,
                  onTap: () async {
                    // Show confirmation dialog before wiping
                    final confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Semua Data?'),
                            content: const Text(
                              'Tindakan ini tidak dapat dibatalkan. Semua data transaksi dan profil akan hilang permanen.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                ),
                                child: const Text('Hapus Permanen'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirmed) {
                      await BackupService.wipeAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Semua data berhasil dihapus. Harap restart aplikasi.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic profile, bool isDark) {
    return FlatCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.surfaceCard,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (profile?.name?.isNotEmpty ?? false)
                    ? profile!.name![0].toUpperCase()
                    : 'U',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? 'Profil Anda',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Atur profil & preferensi',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.danger : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: AppColors.textMuted,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
