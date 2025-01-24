import 'package:flutter/material.dart';
import 'package:outwork/dialogs/add_pr_dialog.dart';
import 'package:outwork/dialogs/add_workout_dialog.dart';

class WorkoutDialogs {
  static Future<void> showAddWorkoutDialog(
      BuildContext context, AddWorkoutDialog addWorkoutDialog) {
     return showDialog(
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
            child: const AddWorkoutDialog(),
          ),
        );
      },
    );
  }

  static Future<void> showAddPRDialog(BuildContext context, AddPRDialog addPRDialog) {
    return showDialog(
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
            child: const AddPRDialog(),
          ),
        );
      },
    );
  }


}
