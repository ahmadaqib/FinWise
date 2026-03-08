import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/income_setup_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Soft minimalist icon/logo replacement
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkInfoBg : AppColors.infoBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.spa_rounded, // Using a generic calm icon
                    size: 40,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Selamat Datang\ndi FinWise',
                style: AppTextStyles.display.copyWith(
                  color: isDark ? AppColors.textInverse : AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                'Aplikasi manajemen keuangan cerdas yang membantumu merencanakan masa depan dengan tenang. Mari mulai dengan profil dasar.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl * 2),

              const IncomeSetupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
