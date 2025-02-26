import 'package:flutter/material.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:outwork/models/personal_record.dart';
import 'package:outwork/models/workout.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/widgets/toast.dart';
import 'package:provider/provider.dart';

class AddPRDialog extends StatefulWidget {
  const AddPRDialog({super.key});

  @override
  State<AddPRDialog> createState() => _AddPRDialogState();
}

class _AddPRDialogState extends State<AddPRDialog> {
  final _formKey = GlobalKey<FormState>();
  final _maxController = TextEditingController();
  final _repsController = TextEditingController();
  Workout? _selectedWorkout;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedWorkout == null) {
      return;
    }

    try {
      final pr = PersonalRecord(
        workoutId: _selectedWorkout!.id!,
        weight: double.parse(_maxController.text),
        reps: int.parse(_repsController.text),
        date: _selectedDate,
      );

      await DatabaseHelper.instance.insertPersonalRecord(pr);

      if (!mounted) return;
      Navigator.of(context).pop();

      // Force a rebuild of the screen to show the new record
      if (!mounted) return;
      Provider.of<WorkoutProvider>(context, listen: false).notifyListeners();

      showCustomToast('Personal Record added successfully', 'success');
    } catch (e) {
      if (!mounted) return;
      showCustomToast('Error adding PR: ${e.toString()}', 'error');
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
            'New Personal Record',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer<WorkoutProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<Workout>(
                      decoration: const InputDecoration(
                        labelText: 'Workout',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedWorkout,
                      items: provider.workouts.map((Workout workout) {
                        return DropdownMenuItem<Workout>(
                          value: workout,
                          child: Text(workout.name),
                        );
                      }).toList(),
                      onChanged: (Workout? newValue) {
                        setState(() {
                          _selectedWorkout = newValue;
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
                  controller: _maxController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg/lbs)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _submitForm,
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                ),
                child:
                    const Text('Add PR', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _maxController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}
