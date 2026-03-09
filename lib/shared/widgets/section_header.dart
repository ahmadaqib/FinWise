import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
