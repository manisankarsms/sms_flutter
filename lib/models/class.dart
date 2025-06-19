class Class {
  final String id;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String? academicYearName;
  final String? staffId;
  final String? staff;
  final String? subjectId;
  final String? subjectName;

  Class({
    required this.id,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    this.academicYearName,
    this.staffId,
    this.staff,
    this.subjectId,
    this.subjectName,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      staffId: json['staffId'],
      staff: json['staff'],
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'sectionName': sectionName,
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'staffId': staffId,
      'staff': staff,
      'subjectId': subjectId,
      'subjectName': subjectName,
    };
  }
}