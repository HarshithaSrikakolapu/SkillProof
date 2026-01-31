class Certificate {
  final int id;
  final String name;
  final String issuer;
  final String issueDate;
  final String fileUrl;
  final String uploadedAt;

  Certificate({
    required this.id,
    required this.name,
    required this.issuer,
    required this.issueDate,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      name: json['name'],
      issuer: json['issuer'],
      issueDate: json['issue_date'],
      fileUrl: json['file_url'],
      uploadedAt: json['uploaded_at'],
    );
  }
}
