import 'package:flutter/material.dart';
import 'package:outwork/models/skill.dart';
import 'package:outwork/providers/workout_provider.dart';
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _skillNameController,
            decoration: const InputDecoration(labelText: 'Skill Name'),
          ),
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Duration'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
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
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
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
          },
          child: Text(isUpdating ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void addSkill(
      BuildContext context, String skillName, String duration, String status) {
    try {
      Provider.of<WorkoutProvider>(context, listen: false)
          .addSkill(skillName, duration, status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill has been added.'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      throw Exception('Failed to add skill');
    }
  }

  void updateSkill(BuildContext context, int id, String skillName,
      String duration, String status) {
    try {
      Provider.of<WorkoutProvider>(context, listen: false)
          .updateSkill(id, skillName, duration, status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill has been updated.'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      throw Exception('Failed to update skill');
    }
  }

  @override
  void dispose() {
    _skillNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
