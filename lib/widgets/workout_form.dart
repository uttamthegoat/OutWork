import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outwork/models/workout_log.dart';

class WorkoutForm extends StatefulWidget {
  final WorkoutLog? initialWorkout;
  final Function(String name, String category, int sets, int reps,
      double? weight, DateTime date) onSubmit;

  const WorkoutForm({
    super.key,
    this.initialWorkout,
    required this.onSubmit,
  });

  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // _nameController = TextEditingController(
    //     text: widget.initialWorkout?.workoutId.toString() ?? '');
    // _categoryController = TextEditingController();
    // _setsController = TextEditingController(
    //     text: widget.initialWorkout?.sets.toString() ?? '');
    // _repsController = TextEditingController(
    //     text: widget.initialWorkout?.reps.toString() ?? '');
    // _weightController = TextEditingController(
    //     text: widget.initialWorkout?.weight?.toString() ?? '');
    // _selectedDate = widget.initialWorkout?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout Name',
              hintText: 'e.g., Bench Press',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a workout name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category',
              hintText: 'e.g., Chest, Back, Legs',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'Optional',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(
              '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _nameController.text,
                  _categoryController.text,
                  int.parse(_setsController.text),
                  int.parse(_repsController.text),
                  _weightController.text.isNotEmpty
                      ? double.parse(_weightController.text)
                      : null,
                  _selectedDate,
                );
              }
            },
            child: Text(widget.initialWorkout == null
                ? 'Add Workout'
                : 'Update Workout'),
          ),
        ],
      ),
    );
  }
}
