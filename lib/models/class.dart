// class_model.dart
import 'package:equatable/equatable.dart';

class Class extends Equatable {
  final String id;
  final String name;
  final List<String> subjects;
  final String? instructor;

  const Class({
    required this.id,
    required this.name,
    required this.subjects,
    this.instructor,
  });

  Class copyWith({
    String? id,
    String? name,
    List<String>? subjects,
    String? instructor,
  }) {
    return Class(
      id: id ?? this.id,
      name: name ?? this.name,
      subjects: subjects ?? this.subjects,
      instructor: instructor ?? this.instructor,
    );
  }

  @override
  List<Object?> get props => [id, name, subjects, instructor];
}