class Rule {
  final int id;
  final String rule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rule({
    required this.id,
    required this.rule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'] as int,
      rule: json['rule'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rule': rule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}