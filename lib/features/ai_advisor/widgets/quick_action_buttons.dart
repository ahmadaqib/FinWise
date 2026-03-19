import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickActionButtons extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActionButtons({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _ActionButton(
            label: 'Atur Limit',
            icon: LucideIcons.settings2,
            onTap: () => onActionSelected('limit'),
            isDark: isDark,
          ),
          _ActionButton(
            label: 'Cek Budget',
            icon: LucideIcons.wallet,
            onTap: () => onActionSelected('budget'),
            isDark: isDark,
          ),
          _ActionButton(
            label: 'Boros di mana?',
            icon: LucideIcons.trendingUp,
            onTap: () => onActionSelected('kategori'),
            isDark: isDark,
          ),
          _ActionButton(
            label: 'Dana Darurat',
            icon: LucideIcons.shieldCheck,
            onTap: () => onActionSelected('darurat'),
            isDark: isDark,
          ),
          _ActionButton(
            label: 'Kesehatan (FWS)',
            icon: LucideIcons.activity,
            onTap: () => onActionSelected('fws'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textInverse : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
