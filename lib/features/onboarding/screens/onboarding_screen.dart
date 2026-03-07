import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/income_setup_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text(
                'Selamat Datang di FinWise',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi manajemen keuangan cerdas Anda. Mari muai dengan menyiapkan profil keuangan dasar agar AI dapat membantu secara akurat.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              const IncomeSetupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
