import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Map<String, String> navItems = AppConstants.bottomNavBarItems;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center), label: navItems['today']!),
        BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month), label: navItems['history']!),
        BottomNavigationBarItem(
            icon: const Icon(Icons.splitscreen_sharp), label: navItems['split']!),
        BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart), label: navItems['stats']!),
      ],
    );
  }
}
