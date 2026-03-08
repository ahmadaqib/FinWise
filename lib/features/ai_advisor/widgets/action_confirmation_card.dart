import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

enum ActionCardStatus { pending, confirmed, cancelled }

class ActionConfirmationCard extends StatelessWidget {
  final String title;
  final String description;
  final ActionCardStatus status;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ActionConfirmationCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor(isDark), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _headerColor(isDark),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14.5),
                  topRight: Radius.circular(14.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, color: _iconColor, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (status != ActionCardStatus.pending)
                    _StatusBadge(status: status, isDark: isDark),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                description,
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.textInverseSecondary
                      : AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),

            // Action Buttons (only when pending)
            if (status == ActionCardStatus.pending)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(LucideIcons.x, size: 16),
                        label: const Text('Batal'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConfirm,
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Konfirmasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(bool isDark) {
    switch (status) {
      case ActionCardStatus.confirmed:
        return AppColors.success.withValues(alpha: 0.5);
      case ActionCardStatus.cancelled:
        return AppColors.danger.withValues(alpha: 0.3);
      case ActionCardStatus.pending:
        return isDark
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary.withValues(alpha: 0.3);
    }
  }

  Color _headerColor(bool isDark) {
    switch (status) {
      case ActionCardStatus.confirmed:
        return AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08);
      case ActionCardStatus.cancelled:
        return AppColors.danger.withValues(alpha: isDark ? 0.15 : 0.08);
      case ActionCardStatus.pending:
        return AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08);
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case ActionCardStatus.confirmed:
        return LucideIcons.checkCircle2;
      case ActionCardStatus.cancelled:
        return LucideIcons.xCircle;
      case ActionCardStatus.pending:
        return LucideIcons.alertCircle;
    }
  }

  Color get _iconColor {
    switch (status) {
      case ActionCardStatus.confirmed:
        return AppColors.success;
      case ActionCardStatus.cancelled:
        return AppColors.danger;
      case ActionCardStatus.pending:
        return AppColors.primary;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ActionCardStatus status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == ActionCardStatus.confirmed;
    final color = isConfirmed ? AppColors.success : AppColors.danger;
    final label = isConfirmed ? 'Dikonfirmasi' : 'Dibatalkan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
