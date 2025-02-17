class WorkoutSplit {
  final int? id;
  final String day;
  final String workout_name;
  final int workout_id;
  final String category;
  final int reps;
  final int sets;
  final double weight;

  WorkoutSplit({
    this.id,
    required this.day,
    required this.workout_name,
    required this.workout_id,
    required this.category,
    required this.reps,
    required this.sets,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'workout_name': workout_name,
      'workout_id': workout_id,
      'category': category,
      'reps': reps,
      'sets': sets,
      'weight': weight,
    };
  }

  factory WorkoutSplit.fromMap(Map<String, dynamic> map) {
    return WorkoutSplit(
      id: map['id'] as int?,
      day: map['day'] as String,
      workout_name: map['workout_name'] as String,
      workout_id: map['workout_id'],
      category: map['category'] as String,
      reps: map['reps'] as int,
      sets: map['sets'] as int,
      weight: map['weight'] as double ?? 0.0,
    );
  }
}
