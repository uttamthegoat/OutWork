import 'package:flutter/material.dart';
import 'package:outwork/models/skill.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/widgets/toast.dart';
import 'package:provider/provider.dart';

class SkillDialog extends StatefulWidget {
  final Skill? skill;

  const SkillDialog({Key? key, this.skill}) : super(key: key);

  @override
  _SkillDialogState createState() => _SkillDialogState();
}

class _SkillDialogState extends State<SkillDialog> {
  final TextEditingController _skillNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  late String _selectedStatus;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if updating
    if (widget.skill != null) {
      _skillNameController.text = widget.skill!.skillName;
      _durationController.text = widget.skill!.duration;
      _selectedStatus = widget.skill!.status;
    } else {
      _selectedStatus = 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.skill != null;

    return AlertDialog(
      title: Text(isUpdating ? 'Update Skill' : 'Add Skill'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _skillNameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a skill name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the skill duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Not Started',
                  child: Text('Not Started'),
                ),
                DropdownMenuItem(
                  value: 'Learning',
                  child: Text('Learning'),
                ),
                DropdownMenuItem(
                  value: 'Achieved',
                  child: Text('Achieved'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a status';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          style: TextButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (isUpdating) {
                updateSkill(
                  context,
                  widget.skill!.id,
                  _skillNameController.text,
                  _durationController.text,
                  _selectedStatus,
                );
              } else {
                addSkill(
                  context,
                  _skillNameController.text,
                  _durationController.text,
                  _selectedStatus,
                );
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(
            isUpdating ? 'Update' : 'Add',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  void addSkill(
      BuildContext context, String skillName, String duration, String status) {
    try {
      Provider.of<WorkoutProvider>(context, listen: false)
          .addSkill(skillName, duration, status);
      showCustomToast('Skill has been added.', 'success');
    } catch (e) {
      showCustomToast('Error adding skill: ${e.toString()}', 'error');
    }
  }

  void updateSkill(BuildContext context, int id, String skillName,
      String duration, String status) {
    try {
      Provider.of<WorkoutProvider>(context, listen: false)
          .updateSkill(id, skillName, duration, status);
      showCustomToast('Skill has been updated.', 'success');
    } catch (e) {
      showCustomToast('Error updating skill: ${e.toString()}', 'error');
    }
  }

  @override
  void dispose() {
    _skillNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
