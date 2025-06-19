import 'package:intl/intl.dart';

class Exam {
  final String? id;
  final String name;
  final String subjectId;
  final String? subjectName;
  final String? subjectCode;
  final String classId;
  final String? className;
  final String? sectionName;
  final String? academicYearId;
  final String? academicYearName;
  final double maxMarks;
  final DateTime date;

  Exam({
    this.id,
    required this.name,
    required this.subjectId,
    this.subjectName,
    this.subjectCode,
    required this.classId,
    this.className,
    this.sectionName,
    this.academicYearId,
    this.academicYearName,
    required this.maxMarks,
    required this.date,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id']?.toString(), // Add null safety
      name: json['name']?.toString() ?? '', // Add null safety with default
      subjectId: json['subjectId']?.toString() ?? '', // Add null safety with default
      subjectName: json['subjectName']?.toString(), // Already nullable, but add null safety
      subjectCode: json['subjectCode']?.toString(), // Already nullable, but add null safety
      classId: json['classId']?.toString() ?? '', // Add null safety with default
      className: json['className']?.toString(), // Already nullable, but add null safety
      sectionName: json['sectionName']?.toString(), // Already nullable, but add null safety
      academicYearId: json['academicYearId']?.toString(), // Already nullable, but add null safety
      academicYearName: json['academicYearName']?.toString(), // Already nullable, but add null safety
      maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 0.0, // Add null safety with default
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(), // Add null safety with default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'subjectId': subjectId,
      'classId': classId,
      'maxMarks': maxMarks,
      'date': DateFormat('yyyy-MM-dd').format(date),
      if (subjectName != null) 'subjectName': subjectName,
      if (subjectCode != null) 'subjectCode': subjectCode,
      if (className != null) 'className': className,
      if (sectionName != null) 'sectionName': sectionName,
      if (academicYearId != null) 'academicYearId': academicYearId,
      if (academicYearName != null) 'academicYearName': academicYearName,
    };
  }

  Exam copyWith({
    String? id,
    String? name,
    String? subjectId,
    String? subjectName,
    String? subjectCode,
    String? classId,
    String? className,
    String? sectionName,
    String? academicYearId,
    String? academicYearName,
    double? maxMarks,
    DateTime? date,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      sectionName: sectionName ?? this.sectionName,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      maxMarks: maxMarks ?? this.maxMarks,
      date: date ?? this.date,
    );
  }
}