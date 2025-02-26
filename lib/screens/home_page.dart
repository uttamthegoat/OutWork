import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/widgets/bottom_nav_bar.dart';
import 'package:outwork/widgets/app_drawer.dart';
import 'package:outwork/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = AppConstants.pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('OutWork'),
          ),
          drawer: AppDrawer(),
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
  }
}
