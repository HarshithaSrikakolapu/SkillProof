class Credential {
  final String id;
  final String skillName;
  final String level;
  final double score;
  final String issuedAt;
  final String userName;

  Credential({
    required this.id,
    required this.skillName,
    required this.level,
    required this.score,
    required this.issuedAt,
    required this.userName,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'],
      skillName: json['skill_name'],
      level: json['level'],
      score: json['score'],
      issuedAt: json['issued_at'],
      userName: json['user_name'],
    );
  }
}
