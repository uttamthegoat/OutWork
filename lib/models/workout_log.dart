class WorkoutLog {
  final int? id;
  final DateTime date;
  final List<String?> workoutNames;
  final List<int?> workoutReps;
  final List<int?> workoutSets;
  final List<double?> workoutWeights;
  final String status; // 'not_started', 'in_progress', 'completed'

  WorkoutLog({
    this.id,
    required this.date,
    required this.workoutNames,
    required this.workoutReps,
    required this.workoutSets,
    required this.workoutWeights,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'workoutNames': workoutNames,
      'workoutReps': workoutReps,
      'workoutSets': workoutSets,
      'workoutWeights': workoutWeights,
      'status': status,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      workoutNames: (map['workoutNames'] as List<dynamic>).cast<String?>(),
      workoutReps: (map['workoutReps'] as List<dynamic>).cast<int?>(),
      workoutSets: (map['workoutSets'] as List<dynamic>).cast<int?>(),
      workoutWeights: (map['workoutWeights'] as List<dynamic>).cast<double?>(),
      status: map['status'] as String,
    );
  }
}
