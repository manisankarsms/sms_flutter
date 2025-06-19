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
      id: json['id'],
      name: json['name'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      maxMarks: (json['maxMarks'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'subjectId': subjectId,
      'classId': classId,
      'maxMarks': maxMarks,
      'date': date.toIso8601String(),
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
