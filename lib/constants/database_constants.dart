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
    'workout_details': 'DROP TABLE IF EXISTS workout_details',
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
        status TEXT NOT NULL
      )
    ''',
    'workout_details': '''
      CREATE TABLE workout_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_id INTEGER NOT NULL,
        workout_id INTEGER NOT NULL,
        weight REAL,
        sets_data TEXT NOT NULL,  /* Stores JSON array of sets: [{"reps": 10}, {"reps": 12}, {"reps": 8}] */
        FOREIGN KEY (log_id) REFERENCES workout_logs (id) ON DELETE CASCADE,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
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
    'skills': '''
      CREATE TABLE skills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        skill_name TEXT NOT NULL,
        duration TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''',
  };
}
