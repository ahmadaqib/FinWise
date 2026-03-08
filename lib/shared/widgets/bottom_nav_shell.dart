import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../features/ai_advisor/screens/ai_advisor_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    ReportsScreen(),
    AiAdvisorScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          indicatorColor: isDark
              ? AppColors.primaryMuted.withOpacity(0.3)
              : AppColors.primaryMuted,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textInverseSecondary
                  : AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return IconThemeData(
              color: isDark
                  ? AppColors.textInverseSecondary
                  : AppColors.textSecondary,
              size: 24,
            );
          }),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                selectedIcon: Icon(
                  LucideIcons.layoutGrid,
                ), // Slightly bolder/different icon for active state
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.list),
                selectedIcon: Icon(LucideIcons.listTodo),
                label: 'Transaksi',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.barChart2),
                selectedIcon: Icon(LucideIcons.barChart),
                label: 'Laporan',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.sparkles),
                selectedIcon: Icon(LucideIcons.bot),
                label: 'AI Advisor',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.settings),
                selectedIcon: Icon(
                  LucideIcons.settings,
                ), // Same icon, boldest by theme
                label: 'Setelan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
