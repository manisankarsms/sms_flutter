// complete_marks.dart

class CompleteMarksData {
  final String className;
  final String sectionName;
  final String academicYear;
  final String examName;
  final DateTime examDate;
  final List<SubjectInfo> subjects;
  final List<StudentCompleteMarks> students;

  CompleteMarksData({
    required this.className,
    required this.sectionName,
    required this.academicYear,
    required this.examName,
    required this.examDate,
    required this.subjects,
    required this.students,
  });

  factory CompleteMarksData.fromJson(Map<String, dynamic> json) {
    return CompleteMarksData(
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYear: json['academicYear'] ?? '',
      examName: json['examName'] ?? '',
      examDate: DateTime.parse(json['examDate']),
      subjects: (json['subjects'] as List<dynamic>)
          .map((subject) => SubjectInfo.fromJson(subject))
          .toList(),
      students: (json['students'] as List<dynamic>)
          .map((student) => StudentCompleteMarks.fromJson(student))
          .toList(),
    );
  }
}

class SubjectInfo {
  final String subjectName;
  final String? subjectCode;
  final int maxMarks;

  SubjectInfo({
    required this.subjectName,
    this.subjectCode,
    required this.maxMarks,
  });

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'],
      maxMarks: json['maxMarks'] ?? 0,
    );
  }
}

class StudentCompleteMarks {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final List<SubjectMarkWithGrade> subjectMarks;
  final int totalMarksObtained;
  final int totalMaxMarks;
  final double overallPercentage;

  StudentCompleteMarks({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.subjectMarks,
    required this.totalMarksObtained,
    required this.totalMaxMarks,
    required this.overallPercentage,
  });

  factory StudentCompleteMarks.fromJson(Map<String, dynamic> json) {
    return StudentCompleteMarks(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      subjectMarks: (json['subjectMarks'] as List<dynamic>)
          .map((e) => SubjectMarkWithGrade.fromJson(e))
          .toList(),
      totalMarksObtained: json['totalMarksObtained'] ?? 0,
      totalMaxMarks: json['totalMaxMarks'] ?? 0,
      overallPercentage: (json['overallPercentage'] ?? 0).toDouble(),
    );
  }
}

class SubjectMarkWithGrade {
  final int marksObtained;
  final String? grade;

  SubjectMarkWithGrade({
    required this.marksObtained,
    this.grade,
  });

  factory SubjectMarkWithGrade.fromJson(Map<String, dynamic> json) {
    return SubjectMarkWithGrade(
      marksObtained: json['marksObtained'] ?? 0,
      grade: json['grade'],
    );
  }
}
