import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DatabaseBackupHelper {
  static Future<String> exportDatabase() async {
    try {
      // Check permissions first
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      if (androidVersion >= 30) {
        final status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          await openAppSettings();
          throw Exception('Please grant storage permission from settings');
        }
      } else {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await openAppSettings();
          throw Exception('Please grant storage permission from settings');
        }
      }

      // Get the database file
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'outwork.db'));

      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Use Downloads directory
      final downloadPath = '/storage/emulated/0/Download/OutWork';
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create backup file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath =
          path.join(downloadPath, 'outwork_backup_$timestamp.db');
      await dbFile.copy(backupPath);

      print('Database exported to: $backupPath');
      return backupPath;
    } catch (e) {
      print('Error in exportDatabase: $e');
      rethrow;
    }
  }

  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final androidVersion = androidInfo.version.sdkInt;

    if (androidVersion >= 30) {
      if (!await Permission.manageExternalStorage.isGranted) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Storage Permission Required'),
              content: const Text(
                'This app needs storage access to import/export database files. '
                'Please enable "Allow management of all files" in the next screen.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () => Navigator.pop(context, true),
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            );
          },
        );

        if (result == true) {
          await openAppSettings();
          // Wait for user to return from settings
          await Future.delayed(const Duration(seconds: 2));
          return await Permission.manageExternalStorage.isGranted;
        }
        return false;
      }
      return true;
    } else {
      if (!await Permission.storage.isGranted) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    }
  }

  static Future<void> importDatabase(
      BuildContext context, String filePath) async {
    try {
      final hasPermission = await checkAndRequestPermissions(context);
      if (!hasPermission) {
        throw Exception('Storage permission is required to import database');
      }

      // Close the current database connection
      await DatabaseHelper.instance.close();

      // Get the database directory
      final dbPath = await getDatabasesPath();
      final targetPath = path.join(dbPath, 'outwork.db');

      // Copy the imported file to the database location
      final File importedFile = File(filePath);
      await importedFile.copy(targetPath);

      // Reopen the database
      await DatabaseHelper.instance.database;
    } catch (e) {
      print('Error importing database: $e');
      rethrow;
    }
  }
}
