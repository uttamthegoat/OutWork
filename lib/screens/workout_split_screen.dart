import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/dialogs/add_split_dialog.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/models/workout_split.dart';
import 'package:outwork/providers/theme_provider.dart';

class WorkoutSplitScreen extends StatefulWidget {
  const WorkoutSplitScreen({super.key});

  @override
  State<WorkoutSplitScreen> createState() => _WorkoutSplitScreenState();
}

class _WorkoutSplitScreenState extends State<WorkoutSplitScreen> {
  final PageController _pageController = PageController();
  int _currentPage = DateTime.now().weekday - 1;
  final List<String> weekDays = AppConstants.weekDays;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentPage);
      _fetchWorkoutsForCurrentDay();
    });
  }

  void _fetchWorkoutsForCurrentDay() {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    provider.fetchWorkoutSplitsForDay(weekDays[_currentPage]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {

        return Scaffold(
          appBar: AppBar(
            title: Text(weekDays[_currentPage]),
          ),
          body: Column(
            children: [
              _buildWeekDayIndicator(themeProvider),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _fetchWorkoutsForCurrentDay();
                  },
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return _buildDayWorkouts(weekDays[_currentPage]);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddWorkoutSplitDialog(
                currentDay: weekDays[_currentPage],
              ),
            ),
            label: const Text('Add Workout'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildWeekDayIndicator(ThemeProvider themeProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _currentPage;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDays[index].substring(0, 3),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayWorkouts(String day) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchWorkoutSplitsForDay(day);
            if (!mounted) return;
            Provider.of<WorkoutProvider>(context, listen: false)
                .notifyListeners();
          },
          child: FutureBuilder<List<WorkoutSplit>>(
            future: provider.fetchWorkoutSplitsForDay(day),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final workoutSplits = provider.workoutSplits;

              return ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: workoutSplits.isEmpty
                    ? [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text('No workouts for this day'),
                          ),
                        ),
                      ]
                    : workoutSplits.map((split) {
                        return ListTile(
                          title: Text(split.workout_name),
                          subtitle: Text(
                              'Reps: ${split.reps} | Category: ${split.category}'),
                        );
                      }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}
