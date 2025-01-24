import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outwork/models/goal.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _goalNameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final goal = {
                          'goal_name': _goalNameController.text,
                          'deadline': _selectedDate.toIso8601String().split('T').first,
                        };
                        try {
                          await Provider.of<WorkoutProvider>(context,
                                  listen: false)
                              .addGoal(goal);
                          if (mounted) {
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          // Handle error
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    super.dispose();
  }
}
