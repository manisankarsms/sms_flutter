class Class {
  final String id;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String academicYearName;
  final String? staffId;
  final String? staff;
  final List<String>? subjectIds;
  final List<String>? subjectNames;

  Class({
    required this.id,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    required this.academicYearName,
    this.staffId,
    this.staff,
    this.subjectIds,
    this.subjectNames,
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
      subjectIds: json['subjectIds'] != null
          ? List<String>.from(json['subjectIds'])
          : null,
      subjectNames: json['subjectNames'] != null
          ? List<String>.from(json['subjectNames'])
          : null,
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
      'subjectIds': subjectIds,
      'subjectNames': subjectNames,
    };
  }
}