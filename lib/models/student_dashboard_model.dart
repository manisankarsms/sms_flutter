class StudentDashboardModel {
  final String studentId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String createdAt;
  final String updatedAt;
  final List<AcademicAssignment> academicAssignments;
  final CurrentAcademicYear currentAcademicYear;
  final List<Subject> subjects;
  final List<AttendanceRecord> attendanceRecords;
  final AttendanceStatistics attendanceStatistics;
  final List<AttendanceRecord> recentAttendance;
  final List<dynamic> examResults; // Can be made more specific if needed
  final AcademicPerformance academicPerformance;
  final List<dynamic> subjectPerformance; // Can be made more specific if needed
  final List<UpcomingExam> upcomingExams;
  final List<ClassTeacher> classTeachers;

  StudentDashboardModel({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.academicAssignments,
    required this.currentAcademicYear,
    required this.subjects,
    required this.attendanceRecords,
    required this.attendanceStatistics,
    required this.recentAttendance,
    required this.examResults,
    required this.academicPerformance,
    required this.subjectPerformance,
    required this.upcomingExams,
    required this.classTeachers,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure - the actual data is in json['data']
    final data = json['data'] ?? json;

    return StudentDashboardModel(
      studentId: data['studentId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      createdAt: data['createdAt'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
      academicAssignments: (data['academicAssignments'] as List<dynamic>?)
          ?.map((e) => AcademicAssignment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      currentAcademicYear: CurrentAcademicYear.fromJson(data['currentAcademicYear'] ?? {}),
      subjects: (data['subjects'] as List<dynamic>?)
          ?.map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      attendanceRecords: (data['attendanceRecords'] as List<dynamic>?)
          ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      attendanceStatistics: AttendanceStatistics.fromJson(data['attendanceStatistics'] ?? {}),
      recentAttendance: (data['recentAttendance'] as List<dynamic>?)
          ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      examResults: data['examResults'] ?? [],
      academicPerformance: AcademicPerformance.fromJson(data['academicPerformance'] ?? {}),
      subjectPerformance: data['subjectPerformance'] ?? [],
      upcomingExams: (data['upcomingExams'] as List<dynamic>?)
          ?.map((e) => UpcomingExam.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      classTeachers: (data['classTeachers'] as List<dynamic>?)
          ?.map((e) => ClassTeacher.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'academicAssignments': academicAssignments.map((e) => e.toJson()).toList(),
      'currentAcademicYear': currentAcademicYear.toJson(),
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'attendanceRecords': attendanceRecords.map((e) => e.toJson()).toList(),
      'attendanceStatistics': attendanceStatistics.toJson(),
      'recentAttendance': recentAttendance.map((e) => e.toJson()).toList(),
      'examResults': examResults,
      'academicPerformance': academicPerformance.toJson(),
      'subjectPerformance': subjectPerformance,
      'upcomingExams': upcomingExams.map((e) => e.toJson()).toList(),
      'classTeachers': classTeachers.map((e) => e.toJson()).toList(),
    };
  }
}

class AcademicAssignment {
  final String assignmentId;
  final String classId;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String academicYearName;
  final String academicYearStartDate;
  final String academicYearEndDate;
  final bool isActiveYear;

  AcademicAssignment({
    required this.assignmentId,
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    required this.academicYearName,
    required this.academicYearStartDate,
    required this.academicYearEndDate,
    required this.isActiveYear,
  });

  factory AcademicAssignment.fromJson(Map<String, dynamic> json) {
    return AcademicAssignment(
      assignmentId: json['assignmentId'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      academicYearStartDate: json['academicYearStartDate'] ?? '',
      academicYearEndDate: json['academicYearEndDate'] ?? '',
      isActiveYear: json['isActiveYear'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'academicYearStartDate': academicYearStartDate,
      'academicYearEndDate': academicYearEndDate,
      'isActiveYear': isActiveYear,
    };
  }
}

class CurrentAcademicYear {
  final String assignmentId;
  final String classId;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String academicYearName;
  final String academicYearStartDate;
  final String academicYearEndDate;
  final bool isActiveYear;

  CurrentAcademicYear({
    required this.assignmentId,
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    required this.academicYearName,
    required this.academicYearStartDate,
    required this.academicYearEndDate,
    required this.isActiveYear,
  });

  factory CurrentAcademicYear.fromJson(Map<String, dynamic> json) {
    return CurrentAcademicYear(
      assignmentId: json['assignmentId'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      academicYearStartDate: json['academicYearStartDate'] ?? '',
      academicYearEndDate: json['academicYearEndDate'] ?? '',
      isActiveYear: json['isActiveYear'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'academicYearStartDate': academicYearStartDate,
      'academicYearEndDate': academicYearEndDate,
      'isActiveYear': isActiveYear,
    };
  }
}

class Subject {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String classId;
  final String className;
  final String sectionName;
  final String academicYearId;
  final String academicYearName;

  Subject({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.academicYearId,
    required this.academicYearName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
    };
  }
}

class AttendanceRecord {
  final String attendanceId;
  final String classId;
  final String className;
  final String sectionName;
  final String date;
  final String status;

  AttendanceRecord({
    required this.attendanceId,
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      attendanceId: json['attendanceId'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'classId': classId,
      'className': className,
      'sectionName': sectionName,
      'date': date,
      'status': status,
    };
  }
}

class AttendanceStatistics {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final double attendancePercentage;
  final double recentAttendanceRate;

  AttendanceStatistics({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.attendancePercentage,
    required this.recentAttendanceRate,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      totalDays: json['totalDays'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0.0).toDouble(),
      recentAttendanceRate: (json['recentAttendanceRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'attendancePercentage': attendancePercentage,
      'recentAttendanceRate': recentAttendanceRate,
    };
  }
}

class AcademicPerformance {
  final int totalExams;
  final int totalMarksObtained;
  final int totalMaxMarks;
  final double overallPercentage;

  AcademicPerformance({
    required this.totalExams,
    required this.totalMarksObtained,
    required this.totalMaxMarks,
    required this.overallPercentage,
  });

  factory AcademicPerformance.fromJson(Map<String, dynamic> json) {
    return AcademicPerformance(
      totalExams: json['totalExams'] ?? 0,
      totalMarksObtained: json['totalMarksObtained'] ?? 0,
      totalMaxMarks: json['totalMaxMarks'] ?? 0,
      overallPercentage: (json['overallPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExams': totalExams,
      'totalMarksObtained': totalMarksObtained,
      'totalMaxMarks': totalMaxMarks,
      'overallPercentage': overallPercentage,
    };
  }
}

class UpcomingExam {
  final String examId;
  final String examName;
  final String subjectName;
  final String subjectCode;
  final String examDate;
  final int maxMarks;
  final String? startTime;
  final String? endTime;
  final int daysUntilExam;

  UpcomingExam({
    required this.examId,
    required this.examName,
    required this.subjectName,
    required this.subjectCode,
    required this.examDate,
    required this.maxMarks,
    this.startTime,
    this.endTime,
    required this.daysUntilExam,
  });

  factory UpcomingExam.fromJson(Map<String, dynamic> json) {
    return UpcomingExam(
      examId: json['examId'] ?? '',
      examName: json['examName'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      examDate: json['examDate'] ?? '',
      maxMarks: json['maxMarks'] ?? 0,
      startTime: json['startTime'],
      endTime: json['endTime'],
      daysUntilExam: json['daysUntilExam'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examName': examName,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'examDate': examDate,
      'maxMarks': maxMarks,
      'startTime': startTime,
      'endTime': endTime,
      'daysUntilExam': daysUntilExam,
    };
  }
}

class ClassTeacher {
  final String teacherId;
  final String teacherName;
  final String email;
  final String? role;

  ClassTeacher({
    required this.teacherId,
    required this.teacherName,
    required this.email,
    this.role,
  });

  factory ClassTeacher.fromJson(Map<String, dynamic> json) {
    return ClassTeacher(
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'null' ? null : json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'email': email,
      'role': role,
    };
  }
}