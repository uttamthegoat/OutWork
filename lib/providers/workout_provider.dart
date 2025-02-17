// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:outwork/database/database_helper.dart';
import 'package:outwork/models/workout.dart';
import 'package:outwork/models/workout_log.dart';
import 'package:outwork/models/workout_split.dart';
import 'package:outwork/models/goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<WorkoutLog> _workoutLogs = [];
  List<WorkoutSplit> _workoutSplits = [];
  List<Goal> _goals = [];

  int _bestStreak = 0;
  int _currentStreak = 0;

  List<Workout> get workouts => [..._workouts];
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  List<WorkoutSplit> get workoutSplits => _workoutSplits;
  List<Goal> get goals => [..._goals];
  int get bestStreak => _bestStreak;
  int get currentStreak => _currentStreak;

  // Add this property to store workout logs by date
  Map<String, List<Map<String, dynamic>>> _workoutLogsByDate = {};

  // Add getter for workoutLogsByDate
  Map<String, List<Map<String, dynamic>>> get workoutLogsByDate =>
      _workoutLogsByDate;

  Future<void> loadWorkouts() async {
    try {
      final workoutMaps = await DatabaseHelper.instance.getWorkouts();

      _workouts = workoutMaps.map((map) {
        return Workout.fromMap(map);
      }).toList();

      notifyListeners();
    } catch (e) {
      _workouts = [];
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      await DatabaseHelper.instance.insertWorkout(
        workout.toMap(),
        workout.muscleGroups,
      );
      await loadWorkouts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logWorkout(Map<String, dynamic> workoutLog) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final existingLogs = await db.query(
        'workout_logs',
        where: 'date = ?',
        whereArgs: [workoutLog['date']],
      );
      if (existingLogs.isNotEmpty) {
        throw Exception('Today\'s workout has been completed');
      }

      final id = await db.insert('workout_logs', workoutLog);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWorkoutStatus(Map<String, dynamic> workoutLog) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'workout_logs',
        workoutLog,
        where: 'date = ?',
        whereArgs: [DateTime.now().toIso8601String().split('T').first],
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update workout status');
    }
  }

  Future<int> createWorkoutLog(Map<String, dynamic> workoutLog) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('workout_logs', workoutLog);
  }

  Future<void> addWorkoutDetails(Map<String, dynamic> workoutDetails) async {
    final db = await DatabaseHelper.instance.database;
    // Convert sets_data to JSON string before inserting
    workoutDetails['sets_data'] = jsonEncode(workoutDetails['sets_data']);
    await db.insert('workout_details', workoutDetails);
  }

  Future<void> updateWorkoutLog(WorkoutLog workoutLog) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workout_logs',
      workoutLog.toMap(),
      where: 'id = ?',
      whereArgs: [workoutLog.id],
    );

    final index = _workoutLogs.indexWhere((log) => log.id == workoutLog.id);
    if (index != -1) {
      _workoutLogs[index] = workoutLog;
      notifyListeners();
    }
  }

  Future<void> deleteWorkoutLog(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'workout_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    _workoutLogs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  Future<List<WorkoutSplit>> fetchWorkoutSplitsForDay(String day) async {
    final maps = await DatabaseHelper.instance.getWorkoutSplitsForDay(day);
    _workoutSplits = maps.map((map) {
      return WorkoutSplit(
          id: map['id'] as int?,
          day: map['day'] as String? ?? '',
          workout_name: map['workout_name'] as String? ?? '',
          workout_id: map['workout_id'],
          category: map['category'] as String? ?? '');
    }).toList();
    return _workoutSplits;
  }

  Future<void> deleteWorkoutSplit(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'workout_split',
        where: 'id = ?',
        whereArgs: [id],
      );

      _workoutSplits.removeWhere((split) => split.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting workout split: $e');
      rethrow;
    }
  }

  Future<bool> isWorkoutFinished() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final today = DateTime.now().toIso8601String().split('T').first;
      final List<Map<String, dynamic>> result = await db.query(
        'workout_logs',
        where: 'date = ? AND status = ?',
        whereArgs: [today, 'Completed'],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking workout status: $e');
      return false;
    }
  }

  Future<bool> hasActiveWorkoutForToday() async {
    try {
      final today = DateTime.now();
      final date = today.toIso8601String().split('T').first;

      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> result = await db.query(
        'workout_logs',
        where: 'date = ? AND status = ?',
        whereArgs: [date, 'In Progress'],
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchWorkoutLogs() async {
    final db = await DatabaseHelper.instance.database;

    // Join workout_logs with workout_details and workouts to get all necessary information
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        wl.date,
        wl.status,
        w.name as workout_name,
        wd.weight,
        wd.sets_data
      FROM workout_logs wl
      JOIN workout_details wd ON wl.id = wd.log_id
      JOIN workouts w ON wd.workout_id = w.id
      ORDER BY wl.date DESC
    ''');

    // Group results by date
    final Map<String, List<Map<String, dynamic>>> groupedLogs = {};

    for (var result in results) {
      final date = result['date'] as String;
      if (!groupedLogs.containsKey(date)) {
        groupedLogs[date] = [];
      }
      groupedLogs[date]!.add(result);
    }

    _workoutLogsByDate = groupedLogs;
    notifyListeners();
  }

  Future<void> loadGoals(String getType) async {
    try {
      if (getType == "fetch") {
        if (_goals.isNotEmpty) {
          return;
        }
      }
      final loadedGoals = await DatabaseHelper.instance.getGoals();
      _goals = loadedGoals;
      notifyListeners();
    } catch (e) {
      _goals = [];
      notifyListeners();
    }
  }

  Future<void> addGoal(Map<String, dynamic> goal) async {
    try {
      final id = await DatabaseHelper.instance.insertGoal(goal);
      await loadGoals("refresh");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await DatabaseHelper.instance.deleteGoal(id);
      _goals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await DatabaseHelper.instance.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadQuickStats() async {
    try {
      _currentStreak = await getCurrentStreak();

      // Initialize SharedPreferences safely
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print('Error initializing SharedPreferences: $e');
        prefs = null;
      }

      // Handle SharedPreferences data
      if (prefs != null) {
        final storedBestStreak = prefs.getInt('bestStreak') ?? 0;
        if (_currentStreak > storedBestStreak) {
          await prefs.setInt('bestStreak', _currentStreak);
          _bestStreak = _currentStreak;
        } else {
          _bestStreak = storedBestStreak;
        }
      } else {
        // Fallback if SharedPreferences is not available
        _bestStreak = _currentStreak;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading quick stats: $e');
      _bestStreak = 0;
      _currentStreak = 0;
      notifyListeners();
    }
  }

  Future<int> getCurrentStreak() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final today = DateTime.now();
      int streak = 0;

      // Get all completed workouts ordered by date
      final List<Map<String, dynamic>> logs = await db.query(
        'workout_logs',
        where: 'status = ? AND date <= ?',
        whereArgs: ['Completed', today.toIso8601String().split('T').first],
        orderBy: 'date DESC',
      );

      if (logs.isEmpty) {
        return 0;
      }

      // Calculate streak
      DateTime? lastDate;
      for (var log in logs) {
        final currentDate = DateTime.parse(log['date'] as String);

        if (lastDate == null) {
          // First entry
          lastDate = currentDate;
          streak = 1;
          continue;
        }

        // Check if dates are consecutive
        final difference = lastDate.difference(currentDate).inDays;
        if (difference == 1) {
          streak++;
          lastDate = currentDate;
        } else {
          // Break in streak found
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }
}
