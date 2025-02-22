class Skill {
  final int id;
  final String skillName;
  final String duration;
  final String status;

  Skill(
      {required this.id,
      required this.skillName,
      required this.duration,
      required this.status});

  // Factory method to create a Skill from a map
  factory Skill.fromMap(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      skillName: json['skill_name'] as String,
      duration: json['duration'] as String,
      status: json['status'] as String,
    );
  }
}
