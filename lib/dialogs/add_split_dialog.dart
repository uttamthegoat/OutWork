import 'package:flutter/material.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class AddWorkoutSplitDialog extends StatefulWidget {
  final String currentDay;

  const AddWorkoutSplitDialog({super.key, required this.currentDay});

  @override
  State<AddWorkoutSplitDialog> createState() => _AddWorkoutSplitDialogState();
}

class _AddWorkoutSplitDialogState extends State<AddWorkoutSplitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  int? _selectedWorkoutId;

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedWorkoutId != null) {
      final workoutSplit = {
        'day': widget.currentDay,
        'workout': _selectedWorkoutId!,
        'reps': int.parse(_repsController.text),
      };

      try {
        await DatabaseHelper.instance.insertWorkoutSplit(workoutSplit);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Optionally, notify listeners if you want to update the UI
        Provider.of<WorkoutProvider>(context, listen: false).fetchWorkoutSplitsForDay(widget.currentDay);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding workout: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Workout'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Day: ${widget.currentDay}'),
            const SizedBox(height: 16),
            Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Workout',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedWorkoutId,
                  items: provider.workouts.map((workout) {
                    return DropdownMenuItem<int>(
                      value: workout.id,
                      child: Text(workout.name),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedWorkoutId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a workout';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of reps';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submitForm(context),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
