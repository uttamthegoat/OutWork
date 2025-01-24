class Goal {
  final int? id;
  final String goalName;
  final DateTime deadline;

  Goal({
    this.id,
    required this.goalName,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_name': goalName,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      goalName: map['goal_name'],
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
