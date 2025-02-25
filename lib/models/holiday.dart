import 'package:equatable/equatable.dart';

class Holiday extends Equatable {
  final int id;
  final String name;
  final String date;
  final String description;
  final bool isPublicHoliday;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.isPublicHoliday,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      description: json['description'],
      isPublicHoliday: json['isPublicHoliday'],
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

  @override
  List<Object?> get props => [id, name, date, description, isPublicHoliday];
}