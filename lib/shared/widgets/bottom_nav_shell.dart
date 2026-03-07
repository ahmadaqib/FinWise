import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.list),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.barChart2),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.sparkles),
            label: 'AI Advisor',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
