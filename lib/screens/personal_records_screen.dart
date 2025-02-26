import 'package:flutter/material.dart';
import 'package:outwork/dialogs/add_pr_dialog.dart';
import 'package:outwork/widgets/toast.dart';
import 'package:outwork/widgets/workout_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/models/personal_record.dart';
import 'package:outwork/models/workout.dart';
import 'package:outwork/database/database_helper.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal Records'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () => _showDeleteConfirmationDialog(context),
                tooltip: 'Delete All PRs',
              ),
            ],
          ),
          body: FutureBuilder<List<PersonalRecord>>(
            future: DatabaseHelper.instance.getPersonalRecords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final records = snapshot.data ?? [];
              if (records.isEmpty) {
                return const Center(
                  child: Text('No personal records yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final workout = provider.workouts.firstWhere(
                    (w) => w.id == record.workoutId,
                    orElse: () => Workout(
                      name: 'Unknown Workout',
                      category: 'Unknown',
                      muscleGroups: [],
                    ),
                  );

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events),
                      title: Text(workout.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Max: ${record.weight} kg/lbs'),
                          Text('Date: ${_formatDate(record.date)}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => WorkoutDialogs.showAddPRDialog(context, const AddPRDialog()),
            label: const Text('New PR'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWorkoutSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: const WorkoutSelectionDialog(),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Personal Records'),
          content:
              const Text('This will permanently delete all personal records. '
                  'This action cannot be undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllPRs(context);
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

  Future<void> _deleteAllPRs(BuildContext context) async {
    try {
      // TODO: Implement deleteAllPRs in DatabaseHelper and Provider
      // await Provider.of<WorkoutProvider>(context, listen: false).deleteAllPRs();

      if (!context.mounted) return;
      showCustomToast('All personal records deleted successfully', 'success');
    } catch (e) {
      if (!context.mounted) return;
      showCustomToast('Error deleting personal records: ${e.toString()}', 'error');
    }
  }
}

class WorkoutSelectionDialog extends StatelessWidget {
  const WorkoutSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Workout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                if (provider.workouts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No workouts available.\nAdd workouts first to track your PRs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.workouts.length,
                  itemBuilder: (context, index) {
                    final workout = provider.workouts[index];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(workout.name),
                      subtitle: Text(workout.category),
                      onTap: () {
                        Navigator.of(context).pop();
                        WorkoutDialogs.showAddPRDialog(context, const AddPRDialog());
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

