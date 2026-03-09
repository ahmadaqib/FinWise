import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/ai_advisor/screens/ai_advisor_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';
import '../../providers/nav_provider.dart';

class BottomNavShell extends ConsumerWidget {
  const BottomNavShell({super.key});

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionListScreen(),
    const ReportsScreen(),
    const AiAdvisorScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          elevation: 0,
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary;
            return AppTextStyles.label.copyWith(
              color: color,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary;
            return IconThemeData(color: color, size: 24);
          }),
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                ref.read(navIndexProvider.notifier).state = index,
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.list),
                label: 'Transaksi',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.barChart2),
                label: 'Laporan',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.sparkles),
                label: 'Advisor',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.settings),
                label: 'Setelan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
