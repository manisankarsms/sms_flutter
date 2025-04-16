class StudentMark {
  final String studentId;
  final String studentName;
  final num marksScored;

  StudentMark({
    required this.studentId,
    required this.studentName,
    required this.marksScored,
  });

  factory StudentMark.fromJson(Map<String, dynamic> json) {
    return StudentMark(
      studentId: json['studentId'],
      studentName: json['studentName'],
      marksScored: json['marksScored'] ?? 0,
    );
  }
}