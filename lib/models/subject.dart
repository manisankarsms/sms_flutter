class Subject {
  final String id;
  final String name;
  final String code;
  final String description;

  Subject({required this.id, required this.name, required this.code, required this.description});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
    };
  }
}