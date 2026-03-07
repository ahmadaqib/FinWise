import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/user_profile_repository.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'shared/widgets/bottom_nav_shell.dart';
import 'providers/budget_provider.dart';

class FinWiseApp extends ConsumerWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = UserProfileRepository().hasProfile();

    // Globally watch the home widget sync provider
    ref.watch(homeWidgetSyncProvider);

    return MaterialApp(
      title: 'FinWise Personal',
      theme: AppTheme.lightTheme,
      home: hasProfile ? const BottomNavShell() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
