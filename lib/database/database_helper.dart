import 'package:outwork/constants/database_constants.dart';
import 'package:outwork/models/goal.dart';
import 'package:outwork/models/workout_log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:outwork/models/personal_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Delete existing database to force recreation
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 3, // Increment version number
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const deleteQueries = DatabaseConstants.deleteQueries;
      // Drop existing tables if they exist
      for (var query in deleteQueries.values) {
        await db.execute(query);
      }
      // Recreate tables
      await _createTables(db, newVersion);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Create workouts table
    const createQueries = DatabaseConstants.createQueries;
    for (var query in createQueries.values) {
      await db.execute(query);
    }   
  }

  Future<int> insertWorkout(
      Map<String, dynamic> workoutData, List<String> muscleGroups) async {
    final db = await database;
    int workoutId = 0;

    try {
      await db.transaction((txn) async {
        // Insert workout
        workoutId = await txn.insert('workouts', {
          'name': workoutData['name'],
          'category': workoutData['category'],
        });

        // Insert muscle groups
        for (String muscleGroup in muscleGroups) {
          await txn.insert('workout_muscle_groups', {
            'workout_id': workoutId,
            'muscle_group': muscleGroup,
          });
        }
      });

      return workoutId;
    } catch (e, stackTrace) {
      print('Error in insertWorkout: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    try {
      // Use a single JOIN query to get workouts with their muscle groups
      final List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT 
          w.*,
          GROUP_CONCAT(wmg.muscle_group) as muscle_groups
        FROM workouts w
        LEFT JOIN workout_muscle_groups wmg ON w.id = wmg.workout_id
        GROUP BY w.id
      ''');

      // Process the results to convert comma-separated muscle groups into a list
      final result = rows.map((row) {
        final muscleGroupsStr = row['muscle_groups'] as String?;
        return {
          'id': row['id'],
          'name': row['name'],
          'category': row['category'],
          'muscle_groups': muscleGroupsStr?.split(',') ?? [],
        };
      }).toList();

      return result;
    } catch (e, stackTrace) {
      print('Error in getWorkouts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> deleteAllWorkouts() async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete from workout_muscle_groups first (foreign key constraint)
      await txn.delete('workout_muscle_groups');

      // Delete from workouts
      await txn.delete('workouts');
    });
  }

  Future<List<PersonalRecord>> getPersonalRecords() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'personal_records',
        orderBy: 'date DESC',
      );

      return maps.map((map) => PersonalRecord.fromMap(map)).toList();
    } catch (e, stackTrace) {
      print('Error in getPersonalRecords: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<int> insertPersonalRecord(PersonalRecord record) async {
    final db = await database;
    try {
      return await db.insert(
        'personal_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting personal record: $e');
      throw Exception('Failed to insert personal record');
    }
  }

  Future<int> insertWorkoutSplit(Map<String, dynamic> workoutSplit) async {
    final db = await database;
    return await db.insert(
      'workout_split',
      workoutSplit,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWorkoutSplitsForDay(String day) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ws.id, ws.day, ws.reps, ws.sets, ws.weight, ws.workout as workout_id, w.name AS workout_name, w.category
      FROM workout_split ws
      JOIN workouts w ON ws.workout = w.id
      WHERE ws.day = ?
    ''', [day]);

    return maps;
  }

  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_logs');
    return maps.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT wl.id, wl.date, wl.status,
      w1.name as workout_1, 
      wl.workout_1_reps,
      wl.workout_1_sets,
      wl.workout_1_weights,
      w2.name as workout_2, 
      wl.workout_2_reps,
      wl.workout_2_sets,
      wl.workout_2_weights,
      w3.name as workout_3, 
      wl.workout_3_reps,
      wl.workout_3_sets,
      wl.workout_3_weights,
      w4.name as workout_4, 
      wl.workout_4_reps,
      wl.workout_4_sets,
      wl.workout_4_weights,
      w5.name as workout_5, 
      wl.workout_5_reps,
      wl.workout_5_sets,
      wl.workout_5_weights,
      w6.name as workout_6, 
      wl.workout_6_reps,
      wl.workout_6_sets,
      wl.workout_6_weights,
      wl.status
      FROM workout_logs wl
      LEFT JOIN workouts w1 ON wl.workout_1 = w1.id
      LEFT JOIN workouts w2 ON wl.workout_2 = w2.id
      LEFT JOIN workouts w3 ON wl.workout_3 = w3.id
      LEFT JOIN workouts w4 ON wl.workout_4 = w4.id
      LEFT JOIN workouts w5 ON wl.workout_5 = w5.id
      LEFT JOIN workouts w6 ON wl.workout_6 = w6.id
    ''');
    return maps;
  }

    // Add CRUD operations for goals
  Future<int> insertGoal(Map<String, dynamic> goal) async {
    final db = await database;
    return await db.insert('goals', goal);
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

    Future<int> updateGoal(Goal goal) async {
    final db = await database;
    try {
      return await db.update(
        'goals',
        goal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
    } catch (e) {
      print('Error updating goal: $e');
      throw Exception('Failed to update goal');
    }
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'goals',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting goal: $e');
      throw Exception('Failed to delete goal');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
