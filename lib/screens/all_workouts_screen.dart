import 'package:flutter/material.dart';
import 'package:outwork/dialogs/add_workout_dialog.dart';
import 'package:outwork/widgets/workout_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/database/database_helper.dart';

class AllWorkoutsScreen extends StatefulWidget {
  const AllWorkoutsScreen({super.key});

  @override
  State<AllWorkoutsScreen> createState() => _AllWorkoutsScreenState();
}

class _AllWorkoutsScreenState extends State<AllWorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    // Load workouts when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).loadWorkouts();
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Workouts'),
          content: const Text(
              'This will permanently delete all workouts and related data. '
              'This action cannot be undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllWorkouts(context);
              },
              child: Text(
                'Delete All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllWorkouts(BuildContext context) async {
    try {
      await DatabaseHelper.instance.deleteAllWorkouts();
      // Refresh the workout list through the provider
      if (context.mounted) {
        await Provider.of<WorkoutProvider>(context, listen: false)
            .loadWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All workouts deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting workouts: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<WorkoutProvider>(context, listen: false)
                  .loadWorkouts();
            },
            tooltip: 'Refresh Workouts',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _showDeleteConfirmationDialog(context),
            tooltip: 'Delete All Workouts',
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {

          if (provider.workouts.isEmpty) {
            return const Center(
              child: Text('No workouts added yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.workouts.length,
            itemBuilder: (context, index) {
              final workout = provider.workouts[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.category),
                      const SizedBox(height: 4),
                      if (workout.muscleGroups.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: workout.muscleGroups.map((group) {
                            return Chip(
                              label: Text(
                                group,
                                style: const TextStyle(fontSize: 12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                            );
                          }).toList(),
                        )
                      else
                        const Text('No muscle groups specified'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Show workout details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => WorkoutDialogs.showAddWorkoutDialog(context, const AddWorkoutDialog()),
        label: const Text('New Workout'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

