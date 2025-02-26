import 'package:flutter/material.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:outwork/models/workout.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/widgets/toast.dart';
import 'package:provider/provider.dart';

class AddWorkoutSplitDialog extends StatefulWidget {
  final String currentDay;

  const AddWorkoutSplitDialog({super.key, required this.currentDay});

  @override
  State<AddWorkoutSplitDialog> createState() => _AddWorkoutSplitDialogState();
}

class _AddWorkoutSplitDialogState extends State<AddWorkoutSplitDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedWorkoutId;

  @override
  void dispose() {
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedWorkoutId != null) {
      final workoutSplit = {
        'day': widget.currentDay,
        'workout': _selectedWorkoutId!,
      };

      try {
        await DatabaseHelper.instance.insertWorkoutSplit(workoutSplit);

        Navigator.of(context).pop();
        showCustomToast('Workout added successfully', 'success');

        // Optionally, notify listeners if you want to update the UI
        Provider.of<WorkoutProvider>(context, listen: false)
            .fetchWorkoutSplitsForDay(widget.currentDay);
      } catch (e) {
        showCustomToast('Error adding workout: ${e.toString()}', 'error');
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
            Text('Day: ${widget.currentDay}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                final sortedWorkouts = List<Workout>.from(provider.workouts)
                  ..sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                print(sortedWorkouts);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete<Workout>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        // Return an empty list if the input is empty
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Workout>.empty();
                        }
                        // Filter the workouts based on the input text
                        return sortedWorkouts.where((workout) => workout.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      displayStringForOption: (Workout workout) => workout.name,
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Workout',
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                      onSelected: (Workout workout) {
                        setState(() {
                          _selectedWorkoutId = workout.id;
                        });
                      },
                    ),
                    if (provider.workouts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'No workouts available. Please add a workout first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => _submitForm(context),
          style: TextButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
          ),
          child: const Text('Add', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
