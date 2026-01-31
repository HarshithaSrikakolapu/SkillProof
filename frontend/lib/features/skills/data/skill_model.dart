class Skill {
  final int id;
  final String name;
  final String? description;

  Skill({required this.id, required this.name, this.description});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Assessment {
  final int id;
  final int skillId;
  final String title;
  final String description;
  final String difficultyLevel;
  final int timeLimitMinutes;
  final Map<String, dynamic> content;

  Assessment({
    required this.id,
    required this.skillId,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.timeLimitMinutes,
    required this.content,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      skillId: json['skill_id'],
      title: json['title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'],
      timeLimitMinutes: json['time_limit_minutes'],
      content: json['content'],
    );
  }
}
