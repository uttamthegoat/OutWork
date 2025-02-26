import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:outwork/database/database_backup_helper.dart';
import 'package:outwork/widgets/toast.dart';

class DataSettings extends StatefulWidget {
  const DataSettings({super.key});

  @override
  State<DataSettings> createState() => _DataSettingsState();
}

class _DataSettingsState extends State<DataSettings> {
  Future<void> _exportDatabase() async {
    try {
      final exportPath = await DatabaseBackupHelper.exportDatabase();
      if (mounted) {
        showCustomToast('Database exported to: $exportPath', 'success');
      }
    } catch (e) {
      if (mounted) {
        showCustomToast('Error exporting database: $e', 'error');
      }
    }
  }

  Future<void> _importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (!filePath.toLowerCase().endsWith('.db')) {
          if (mounted) {
            showCustomToast('Please select a valid database file (.db)', 'error');
          }
          return;
        }

        await DatabaseBackupHelper.importDatabase(context, filePath);
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Import Successful'),
                content: const Text(
                  'Database imported successfully. The app will now close. '
                  'Please restart the app to see the imported data.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      exit(0); // Force close the app
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomToast('Error importing database: $e', 'error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Settings'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Manage Your Data',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _importDatabase();
                },
                child: const Text('Import Data'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _exportDatabase();
                },
                child: const Text('Export Data'),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose your action above to manage data.',
              ),
            ],
          ),
        ));
  }
}
