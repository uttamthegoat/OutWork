class Workout {
  final int? id;
  final String name;
  final String category;
  final List<String> muscleGroups;

  Workout({
    this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      muscleGroups: (map['muscle_groups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'Workout{id: $id, name: $name, category: $category, muscleGroups: $muscleGroups}';
  }
}
