// lib/models/exam.dart

class Exam {
  final String? id;
  final String title;
  final String description;
  final DateTime? examDate;
  final String? subjectId;
  final String? classId;
  final int? duration; // in minutes
  final double? totalMarks;
  final String? createdBy;
  final DateTime? createdAt;
  final String status; // draft, published, completed, etc.

  Exam({
    this.id,
    required this.title,
    required this.description,
    required this.examDate,
    required this.subjectId,
    required this.classId,
    required this.duration,
    required this.totalMarks,
    this.createdBy,
    this.createdAt,
    this.status = 'draft',
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      examDate: DateTime.parse(json['examDate']),
      subjectId: json['subjectId'],
      classId: json['classId'],
      duration: json['duration'],
      totalMarks: json['totalMarks'].toDouble(),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      status: json['status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'examDate': examDate?.toIso8601String(),
      'subjectId': subjectId,
      'classId': classId,
      'duration': duration,
      'totalMarks': totalMarks,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      'status': status,
    };
  }

  Exam copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? examDate,
    String? subjectId,
    String? classId,
    int? duration,
    double? totalMarks,
    String? createdBy,
    DateTime? createdAt,
    String? status,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      examDate: examDate ?? this.examDate,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      duration: duration ?? this.duration,
      totalMarks: totalMarks ?? this.totalMarks,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}