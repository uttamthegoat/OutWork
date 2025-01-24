import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/models/workout.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class AddWorkoutDialog extends StatefulWidget {
  const AddWorkoutDialog({super.key});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final Set<String> _selectedMuscleGroups = {};
  bool _isDropdownOpen = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedMuscleGroups.isEmpty) {
      return;
    }

    try {
      final workout = Workout(
        name: _nameController.text,
        category: _categoryController.text,
        muscleGroups: _selectedMuscleGroups.toList(),
      );

      await Provider.of<WorkoutProvider>(context, listen: false)
          .addWorkout(workout);

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding workout: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add New Workout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Workout Name',
                        hintText: 'e.g., Bench Press',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a workout name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isDropdownOpen = !_isDropdownOpen;
                        });
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Muscle Groups',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorText: _selectedMuscleGroups.isEmpty
                              ? 'Please select at least one muscle group'
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedMuscleGroups.isEmpty
                                    ? 'Select muscle groups'
                                    : _selectedMuscleGroups.join(', '),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(_isDropdownOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (_isDropdownOpen)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(top: 4),
                          elevation: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: AppConstants.muscleGroups.map((group) {
                                return CheckboxListTile(
                                  title: Text(group),
                                  value: _selectedMuscleGroups.contains(group),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected ?? false) {
                                        _selectedMuscleGroups.add(group);
                                      } else {
                                        _selectedMuscleGroups.remove(group);
                                      }
                                    });
                                  },
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'e.g., Strength, Cardio',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
