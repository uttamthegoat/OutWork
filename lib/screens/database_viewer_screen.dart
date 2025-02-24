import 'package:flutter/material.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:outwork/constants/database_constants.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final List<String> _tables = DatabaseConstants.dbTables;


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tables.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Viewer'),
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
