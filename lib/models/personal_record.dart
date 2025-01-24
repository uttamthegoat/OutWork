class PersonalRecord {
  final int? id;
  final int workoutId;
  final double weight;
  final int reps;
  final DateTime date;

  PersonalRecord({
    this.id,
    required this.workoutId,
    required this.weight,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'weight': weight,
      'reps': reps,
      'date': date.toIso8601String(),
    };
  }

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      weight: map['weight'] as double,
      reps: map['reps'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }

  @override
  String toString() {
    return 'PersonalRecord{id: $id, workoutId: $workoutId, weight: $weight, reps: $reps, date: $date}';
  }
}
