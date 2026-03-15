import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/macro_context_provider.dart';
import '../../../services/macro_context_service.dart';
import '../../../shared/widgets/flat_card.dart';

class MacroInfoCarousel extends ConsumerWidget {
  const MacroInfoCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroAsync = ref.watch(macroContextProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.public_rounded,
              size: 18,
              color: isDark ? AppColors.textInverseSecondary : AppColors.info,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Pulse Global',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 16,
                  color: isDark ? AppColors.textInverse : AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => ref.invalidate(macroContextProvider),
              icon: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textInverseSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        macroAsync.when(
          data: (snapshot) {
            final headlines = snapshot?.headlines ?? const <MacroHeadline>[];
            if (headlines.isEmpty) {
              return _MacroStatusCard(
                message: 'Update global belum tersedia. Coba refresh lagi.',
                isDark: isDark,
              );
            }

            return SizedBox(
              height: 178,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: headlines.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  return _MacroHeadlineCard(
                    headline: headlines[index],
                    isDark: isDark,
                  );
                },
              ),
            );
          },
          loading: () => _MacroStatusCard(
            message: 'Memuat update ekonomi/politik global...',
            isDark: isDark,
          ),
          error: (_, _) => _MacroStatusCard(
            message: 'Gagal memuat update global. Tap refresh untuk coba lagi.',
            isDark: isDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Info ringkas untuk awareness macro. Keputusan tetap mengacu algoritma budget personal.',
          style: AppTextStyles.caption.copyWith(
            color: isDark
                ? AppColors.textInverseSecondary
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _MacroHeadlineCard extends StatelessWidget {
  final MacroHeadline headline;
  final bool isDark;

  const _MacroHeadlineCard({required this.headline, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final themeColor = headline.theme == 'geopolitics'
        ? AppColors.warning
        : AppColors.info;
    final cardColor = isDark
        ? AppColors.darkInfoBg.withValues(alpha: 0.7)
        : AppColors.infoBg;

    return SizedBox(
      width: 292,
      child: FlatCard(
        backgroundColor: cardColor,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    headline.theme == 'geopolitics' ? 'Geo' : 'Macro',
                    style: AppTextStyles.label.copyWith(
                      color: themeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatHeadlineDate(headline.publishedAt),
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textInverseSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Text(
                headline.title,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textInverse : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${headline.domain} • ${headline.sourceCountry}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textInverseSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHeadlineDate(DateTime value) {
    return DateFormat('d MMM', 'id_ID').format(value.toLocal());
  }
}

class _MacroStatusCard extends StatelessWidget {
  final String message;
  final bool isDark;

  const _MacroStatusCard({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      backgroundColor: isDark ? AppColors.darkSubtle : AppColors.surfaceSubtle,
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: isDark
              ? AppColors.textInverseSecondary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
