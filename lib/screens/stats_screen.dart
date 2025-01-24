import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/dialogs/add_goal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    _loadGoals("fetch");
    setBestStreak();
    _loadQuickStats();
  }

  Future<void> _loadGoals(String getType) async {
    await Provider.of<WorkoutProvider>(context, listen: false)
        .loadGoals(getType);
  }

  void setBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestStreak', 0);
  }

  Future<void> _loadQuickStats() async {
    await Provider.of<WorkoutProvider>(context, listen: false).loadQuickStats();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_outlined),
                Text(
                  "Overall Statistics",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildGoals(context),
            const SizedBox(height: 24),
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoals(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Goals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _loadGoals("refresh"),
                      child: const Icon(Icons.refresh),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return const AddGoalDialog();
                          },
                        );
                        if (result == true) {
                          _loadGoals(
                              "fetch"); // Reload goals after adding new one
                        }
                      },
                      style: TextButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Goal'),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            if (goals.isEmpty)
              const Center(
                child: Text('No goals added yet'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return Card(
                    child: ListTile(
                      title: Text(goal.goalName),
                      subtitle: Text(
                        'Deadline: ${DateFormat('yyyy-MM-dd').format(goal.deadline)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await provider.deleteGoal(goal.id!);
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _loadQuickStats(),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Best Streak', provider.bestStreak.toString(), 'days'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Current Streak',
                      provider.currentStreak.toString(), 'days'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(unit),
          ],
        ),
      ),
    );
  }
}
