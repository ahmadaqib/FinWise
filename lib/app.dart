import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/user_profile_repository.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'shared/widgets/bottom_nav_shell.dart';

class FinWiseApp extends StatelessWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasProfile = UserProfileRepository().hasProfile();

    return MaterialApp(
      title: 'FinWise Personal',
      theme: AppTheme.lightTheme,
      home: hasProfile ? const BottomNavShell() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
