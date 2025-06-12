import 'package:sms/models/user.dart';

class Subject {
  final String id;
  final String name;
  final String code;
  final String? classSubjectId;

  Subject({required this.id, required this.name, required this.code, this.classSubjectId});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      classSubjectId: json['classSubjectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'classSubjectId' : classSubjectId,
    };
  }
}