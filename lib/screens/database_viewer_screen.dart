import 'package:flutter/material.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:outwork/database/database_backup_helper.dart';
import 'dart:io';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final List<String> _tables = [
    'workouts',
    'workout_muscle_groups',
    'workout_logs',
    'personal_records',
    'workout_split',
    'goals',
  ];

  Future<void> _exportDatabase() async {
    try {
      final exportPath = await DatabaseBackupHelper.exportDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database exported to: $exportPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting database: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a valid database file (.db)'),
                backgroundColor: Colors.red,
              ),
            );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tables.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Viewer'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'export') {
                  await _exportDatabase();
                } else if (value == 'import') {
                  await _importDatabase();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 8),
                      Text('Export Database'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Import Database'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: _tables.map((table) => Tab(text: table)).toList(),
          ),
        ),
        body: TabBarView(
          children:
              _tables.map((table) => _TableViewer(tableName: table)).toList(),
        ),
      ),
    );
  }
}

class _TableViewer extends StatelessWidget {
  final String tableName;

  const _TableViewer({required this.tableName});

  Future<List<Map<String, dynamic>>> _getTableData() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(tableName);
  }

  Future<void> _deleteAllRecords(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Delete All ${tableName.replaceAll('_', ' ').toUpperCase()}'),
        content: Text(
          'Are you sure you want to delete all records from $tableName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete(tableName);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All records from $tableName deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting records: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTableData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No data in $tableName'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _deleteAllRecords(context),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: Text('Delete All ${tableName.replaceAll('_', ' ')}'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final columns = data.first.keys.toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => _deleteAllRecords(context),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: Text('Delete All ${tableName.replaceAll('_', ' ')}'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: columns
                        .map((column) => DataColumn(
                              label: Text(
                                column,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    rows: data.map((row) {
                      return DataRow(
                        cells: columns
                            .map((column) => DataCell(
                                  Text(
                                    row[column]?.toString() ?? 'null',
                                    style: const TextStyle(
                                        fontFamily: 'monospace'),
                                  ),
                                ))
                            .toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
