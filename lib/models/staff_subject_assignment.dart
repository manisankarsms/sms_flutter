class StaffSubjectAssignment {
  final String? id;
  final String? staffId;
  final String? staffName;
  final String? staffEmail;
  final String classSubjectId;
  final String classId;
  final String className;
  final String sectionName;
  final String subjectName;
  final String subjectCode;
  final String? academicYearId;
  final String? academicYearName;

  StaffSubjectAssignment({
    this.id,
    this.staffId,
    this.staffName,
    this.staffEmail,
    required this.classSubjectId,
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.subjectName,
    required this.subjectCode,
    this.academicYearId,
    this.academicYearName,
  });

  factory StaffSubjectAssignment.fromJson(Map<String, dynamic> json) {
    return StaffSubjectAssignment(
      id: json['id'] as String?,
      staffId: json['staffId'] as String?,
      staffName: json['staffName'] as String?,
      staffEmail: json['staffEmail'] as String?,
      classSubjectId: json['classSubjectId'],
      classId: json['classId'],
      className: json['className'],
      sectionName: json['sectionName'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      academicYearId: json['academicYearId'] as String?,
      academicYearName: json['academicYearName'] as String?,
    );
  }
}
