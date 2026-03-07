import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'home_screen.dart';
import 'crops_screen.dart';
import 'tasks_screen.dart';
import 'farmers_screen.dart';
import 'weather_screen.dart';

/// App shell with bottom navigation for primary modules.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  bool get _isAdmin => AuthService.session?.isAdmin ?? false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      CropsScreen(),
      TasksScreen(),
      FarmersScreen(),
      WeatherScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2ECC71).withAlpha(30),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: LocalizationService.tr('Dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            selectedIcon: const Icon(Icons.grass),
            label: LocalizationService.tr('Crops'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: LocalizationService.tr('Tasks'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outlined),
            selectedIcon: const Icon(Icons.people),
            label: _isAdmin
                ? LocalizationService.tr('Farmers')
                : 'Profile',
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud),
            label: LocalizationService.tr('Weather Alerts'),
          ),
        ],
      ),
    );
  }
}
