class DatabaseConstants {
  static const String dbName = 'outwork.db';
  static const String workoutsTable = 'workouts';
  static const String exercisesTable = 'exercises';
  static const String setsTable = 'sets';

  static const Map<String, String> deleteQueries = {
    'workout_muscle_groups': 'DROP TABLE IF EXISTS workout_muscle_groups',
    'personal_records': 'DROP TABLE IF EXISTS personal_records',
    'workout_split': 'DROP TABLE IF EXISTS workout_split',
    'workout_logs': 'DROP TABLE IF EXISTS workout_logs',
    'workouts': 'DROP TABLE IF EXISTS workouts',
  };

  static const Map<String, String> createQueries = {
    'workouts': '''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''',
    'workout_muscle_groups': '''
      CREATE TABLE workout_muscle_groups(
        workout_id INTEGER,
        muscle_group TEXT NOT NULL,
        PRIMARY KEY (workout_id, muscle_group),
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''',
    'workout_logs': '''
      CREATE TABLE workout_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        workout_1 INTEGER,
        workout_1_reps INTEGER,
        workout_1_sets INTEGER,
        workout_1_weights REAL,
        workout_2 INTEGER,
        workout_2_reps INTEGER,
        workout_2_sets INTEGER,
        workout_2_weights REAL,
        workout_3 INTEGER,
        workout_3_reps INTEGER,
        workout_3_sets INTEGER,
        workout_3_weights REAL,
        workout_4 INTEGER,
        workout_4_reps INTEGER,
        workout_4_sets INTEGER,
        workout_4_weights REAL,
        workout_5 INTEGER,
        workout_5_reps INTEGER,
        workout_5_sets INTEGER,
        workout_5_weights REAL,
        workout_6 INTEGER,
        workout_6_reps INTEGER,
        workout_6_sets INTEGER,
        workout_6_weights REAL,
        status TEXT NOT NULL,
        FOREIGN KEY (workout_1) REFERENCES workouts (id) ON DELETE SET NULL,
        FOREIGN KEY (workout_2) REFERENCES workouts (id) ON DELETE SET NULL,
        FOREIGN KEY (workout_3) REFERENCES workouts (id) ON DELETE SET NULL,
        FOREIGN KEY (workout_4) REFERENCES workouts (id) ON DELETE SET NULL,
        FOREIGN KEY (workout_5) REFERENCES workouts (id) ON DELETE SET NULL,
        FOREIGN KEY (workout_6) REFERENCES workouts (id) ON DELETE SET NULL
      )
    ''',
    'personal_records': '''
      CREATE TABLE personal_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''',
    'workout_split': '''
      CREATE TABLE workout_split(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT NOT NULL,
        workout INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        sets INTEGER NOT NULL,
        weight REAL,
        FOREIGN KEY (workout) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''',
    'goals': '''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_name TEXT NOT NULL,
        deadline TEXT NOT NULL
      )
    ''',
  };
}
