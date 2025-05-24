// holiday.dart
class Holiday {
  final int id;
  final String name;
  final String date; // Format: 'yyyy-MM-dd'
  final String? description;
  final bool isPublicHoliday;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    this.description,
    required this.isPublicHoliday,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      description: json['description'],
      isPublicHoliday: json['isPublicHoliday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'description': description,
      'isPublicHoliday': isPublicHoliday,
    };
  }

  Holiday copyWith({
    int? id,
    String? name,
    String? date,
    String? description,
    bool? isPublicHoliday,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      description: description ?? this.description,
      isPublicHoliday: isPublicHoliday ?? this.isPublicHoliday,
    );
  }
}