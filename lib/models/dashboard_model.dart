class DashboardModel {
  final bool success;
  final DashboardData data;
  final String message;

  DashboardModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      success: json['success'] ?? false,
      data: DashboardData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class DashboardData {
  final Overview overview;
  final StudentStatistics studentStatistics;
  final StaffStatistics staffStatistics;
  final ExamStatistics examStatistics;
  final AttendanceStatistics attendanceStatistics;
  final ComplaintStatistics complaintStatistics;
  final AcademicStatistics academicStatistics;
  final HolidayStatistics holidayStatistics;

  DashboardData({
    required this.overview,
    required this.studentStatistics,
    required this.staffStatistics,
    required this.examStatistics,
    required this.attendanceStatistics,
    required this.complaintStatistics,
    required this.academicStatistics,
    required this.holidayStatistics,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      overview: Overview.fromJson(json['overview'] ?? {}),
      studentStatistics: StudentStatistics.fromJson(json['studentStatistics'] ?? {}),
      staffStatistics: StaffStatistics.fromJson(json['staffStatistics'] ?? {}),
      examStatistics: ExamStatistics.fromJson(json['examStatistics'] ?? {}),
      attendanceStatistics: AttendanceStatistics.fromJson(json['attendanceStatistics'] ?? {}),
      complaintStatistics: ComplaintStatistics.fromJson(json['complaintStatistics'] ?? {}),
      academicStatistics: AcademicStatistics.fromJson(json['academicStatistics'] ?? {}),
      holidayStatistics: HolidayStatistics.fromJson(json['holidayStatistics'] ?? {}),
    );
  }
}

class Overview {
  final int totalStudents;
  final int totalStaff;
  final int totalClasses;
  final int totalSubjects;
  final int activeAcademicYears;
  final int upcomingExams;
  final int totalComplaints;
  final int pendingComplaints;
  final double todayAttendanceRate;
  final int totalHolidays;
  final int upcomingHolidays;

  Overview({
    required this.totalStudents,
    required this.totalStaff,
    required this.totalClasses,
    required this.totalSubjects,
    required this.activeAcademicYears,
    required this.upcomingExams,
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.todayAttendanceRate,
    required this.totalHolidays,
    required this.upcomingHolidays,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      totalStudents: json['totalStudents'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      activeAcademicYears: json['activeAcademicYears'] ?? 0,
      upcomingExams: json['upcomingExams'] ?? 0,
      totalComplaints: json['totalComplaints'] ?? 0,
      pendingComplaints: json['pendingComplaints'] ?? 0,
      todayAttendanceRate: (json['todayAttendanceRate'] ?? 0).toDouble(),
      totalHolidays: json['totalHolidays'] ?? 0,
      upcomingHolidays: json['upcomingHolidays'] ?? 0,
    );
  }
}

class StudentStatistics {
  final int totalStudents;
  final List<StudentsByClass> studentsByClass;
  final List<StudentsByAcademicYear> studentsByAcademicYear;
  final List<RecentEnrollment> recentEnrollments;

  StudentStatistics({
    required this.totalStudents,
    required this.studentsByClass,
    required this.studentsByAcademicYear,
    required this.recentEnrollments,
  });

  factory StudentStatistics.fromJson(Map<String, dynamic> json) {
    return StudentStatistics(
      totalStudents: json['totalStudents'] ?? 0,
      studentsByClass: (json['studentsByClass'] as List<dynamic>?)
          ?.map((item) => StudentsByClass.fromJson(item))
          .toList() ?? [],
      studentsByAcademicYear: (json['studentsByAcademicYear'] as List<dynamic>?)
          ?.map((item) => StudentsByAcademicYear.fromJson(item))
          .toList() ?? [],
      recentEnrollments: (json['recentEnrollments'] as List<dynamic>?)
          ?.map((item) => RecentEnrollment.fromJson(item))
          .toList() ?? [],
    );
  }
}

class StudentsByClass {
  final String classId;
  final String className;
  final String sectionName;
  final int studentCount;
  final String academicYearName;

  StudentsByClass({
    required this.classId,
    required this.className,
    required this.sectionName,
    required this.studentCount,
    required this.academicYearName,
  });

  factory StudentsByClass.fromJson(Map<String, dynamic> json) {
    return StudentsByClass(
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      studentCount: json['studentCount'] ?? 0,
      academicYearName: json['academicYearName'] ?? '',
    );
  }
}

class StudentsByAcademicYear {
  final String academicYearId;
  final String academicYearName;
  final int studentCount;

  StudentsByAcademicYear({
    required this.academicYearId,
    required this.academicYearName,
    required this.studentCount,
  });

  factory StudentsByAcademicYear.fromJson(Map<String, dynamic> json) {
    return StudentsByAcademicYear(
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      studentCount: json['studentCount'] ?? 0,
    );
  }
}

class RecentEnrollment {
  final String studentId;
  final String studentName;
  final String className;
  final String sectionName;
  final String academicYearName;
  final String enrollmentDate;

  RecentEnrollment({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.sectionName,
    required this.academicYearName,
    required this.enrollmentDate,
  });

  factory RecentEnrollment.fromJson(Map<String, dynamic> json) {
    return RecentEnrollment(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      enrollmentDate: json['enrollmentDate'] ?? '',
    );
  }
}

class StaffStatistics {
  final int totalStaff;
  final List<StaffByRole> staffByRole;
  final int classTeachers;
  final int subjectTeachers;
  final List<StaffWorkload> staffWorkload;

  StaffStatistics({
    required this.totalStaff,
    required this.staffByRole,
    required this.classTeachers,
    required this.subjectTeachers,
    required this.staffWorkload,
  });

  factory StaffStatistics.fromJson(Map<String, dynamic> json) {
    return StaffStatistics(
      totalStaff: json['totalStaff'] ?? 0,
      staffByRole: (json['staffByRole'] as List<dynamic>?)
          ?.map((item) => StaffByRole.fromJson(item))
          .toList() ?? [],
      classTeachers: json['classTeachers'] ?? 0,
      subjectTeachers: json['subjectTeachers'] ?? 0,
      staffWorkload: (json['staffWorkload'] as List<dynamic>?)
          ?.map((item) => StaffWorkload.fromJson(item))
          .toList() ?? [],
    );
  }
}

class StaffByRole {
  final String role;
  final int count;

  StaffByRole({
    required this.role,
    required this.count,
  });

  factory StaffByRole.fromJson(Map<String, dynamic> json) {
    return StaffByRole(
      role: json['role'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class StaffWorkload {
  final String staffId;
  final String staffName;
  final String email;
  final int classesAssigned;
  final int subjectsAssigned;
  final int totalWorkload;

  StaffWorkload({
    required this.staffId,
    required this.staffName,
    required this.email,
    required this.classesAssigned,
    required this.subjectsAssigned,
    required this.totalWorkload,
  });

  factory StaffWorkload.fromJson(Map<String, dynamic> json) {
    return StaffWorkload(
      staffId: json['staffId'] ?? '',
      staffName: json['staffName'] ?? '',
      email: json['email'] ?? '',
      classesAssigned: json['classesAssigned'] ?? 0,
      subjectsAssigned: json['subjectsAssigned'] ?? 0,
      totalWorkload: json['totalWorkload'] ?? 0,
    );
  }
}

class ExamStatistics {
  final int totalExams;
  final int upcomingExams;
  final List<dynamic> examsBySubject;
  final List<dynamic> examsByClass;
  final List<dynamic> recentExamResults;
  final List<dynamic> upcomingExamSchedules;

  ExamStatistics({
    required this.totalExams,
    required this.upcomingExams,
    required this.examsBySubject,
    required this.examsByClass,
    required this.recentExamResults,
    required this.upcomingExamSchedules,
  });

  factory ExamStatistics.fromJson(Map<String, dynamic> json) {
    return ExamStatistics(
      totalExams: json['totalExams'] ?? 0,
      upcomingExams: json['upcomingExams'] ?? 0,
      examsBySubject: json['examsBySubject'] ?? [],
      examsByClass: json['examsByClass'] ?? [],
      recentExamResults: json['recentExamResults'] ?? [],
      upcomingExamSchedules: json['upcomingExamSchedules'] ?? [],
    );
  }
}

class AttendanceStatistics {
  final double todayAttendanceRate;
  final double weeklyAttendanceRate;
  final double monthlyAttendanceRate;
  final List<dynamic> attendanceByClass;
  final List<dynamic> lowAttendanceStudents;

  AttendanceStatistics({
    required this.todayAttendanceRate,
    required this.weeklyAttendanceRate,
    required this.monthlyAttendanceRate,
    required this.attendanceByClass,
    required this.lowAttendanceStudents,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      todayAttendanceRate: (json['todayAttendanceRate'] ?? 0).toDouble(),
      weeklyAttendanceRate: (json['weeklyAttendanceRate'] ?? 0).toDouble(),
      monthlyAttendanceRate: (json['monthlyAttendanceRate'] ?? 0).toDouble(),
      attendanceByClass: json['attendanceByClass'] ?? [],
      lowAttendanceStudents: json['lowAttendanceStudents'] ?? [],
    );
  }
}

class ComplaintStatistics {
  final int totalComplaints;
  final int pendingComplaints;
  final int resolvedComplaints;
  final List<ComplaintsByCategory> complaintsByCategory;
  final List<ComplaintsByStatus> complaintsByStatus;
  final List<RecentComplaint> recentComplaints;

  ComplaintStatistics({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.resolvedComplaints,
    required this.complaintsByCategory,
    required this.complaintsByStatus,
    required this.recentComplaints,
  });

  factory ComplaintStatistics.fromJson(Map<String, dynamic> json) {
    return ComplaintStatistics(
      totalComplaints: json['totalComplaints'] ?? 0,
      pendingComplaints: json['pendingComplaints'] ?? 0,
      resolvedComplaints: json['resolvedComplaints'] ?? 0,
      complaintsByCategory: (json['complaintsByCategory'] as List<dynamic>?)
          ?.map((item) => ComplaintsByCategory.fromJson(item))
          .toList() ?? [],
      complaintsByStatus: (json['complaintsByStatus'] as List<dynamic>?)
          ?.map((item) => ComplaintsByStatus.fromJson(item))
          .toList() ?? [],
      recentComplaints: (json['recentComplaints'] as List<dynamic>?)
          ?.map((item) => RecentComplaint.fromJson(item))
          .toList() ?? [],
    );
  }
}

class ComplaintsByCategory {
  final String category;
  final int count;

  ComplaintsByCategory({
    required this.category,
    required this.count,
  });

  factory ComplaintsByCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintsByCategory(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ComplaintsByStatus {
  final String status;
  final int count;

  ComplaintsByStatus({
    required this.status,
    required this.count,
  });

  factory ComplaintsByStatus.fromJson(Map<String, dynamic> json) {
    return ComplaintsByStatus(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RecentComplaint {
  final String id;
  final String title;
  final String category;
  final String status;
  final String author;
  final bool isAnonymous;
  final String createdAt;

  RecentComplaint({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.author,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory RecentComplaint.fromJson(Map<String, dynamic> json) {
    return RecentComplaint(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      author: json['author'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class AcademicStatistics {
  final int totalAcademicYears;
  final int activeAcademicYears;
  final int totalClasses;
  final int totalSubjects;
  final int classSubjectMappings;
  final List<AcademicYearDetail> academicYearDetails;

  AcademicStatistics({
    required this.totalAcademicYears,
    required this.activeAcademicYears,
    required this.totalClasses,
    required this.totalSubjects,
    required this.classSubjectMappings,
    required this.academicYearDetails,
  });

  factory AcademicStatistics.fromJson(Map<String, dynamic> json) {
    return AcademicStatistics(
      totalAcademicYears: json['totalAcademicYears'] ?? 0,
      activeAcademicYears: json['activeAcademicYears'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      classSubjectMappings: json['classSubjectMappings'] ?? 0,
      academicYearDetails: (json['academicYearDetails'] as List<dynamic>?)
          ?.map((item) => AcademicYearDetail.fromJson(item))
          .toList() ?? [],
    );
  }
}

class AcademicYearDetail {
  final String academicYearId;
  final String academicYearName;
  final String startDate;
  final String endDate;
  final bool isActive;
  final int totalClasses;
  final int totalStudents;
  final int totalExams;

  AcademicYearDetail({
    required this.academicYearId,
    required this.academicYearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.totalClasses,
    required this.totalStudents,
    required this.totalExams,
  });

  factory AcademicYearDetail.fromJson(Map<String, dynamic> json) {
    return AcademicYearDetail(
      academicYearId: json['academicYearId'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? false,
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalExams: json['totalExams'] ?? 0,
    );
  }
}

class HolidayStatistics {
  final int totalHolidays;
  final int upcomingHolidays;
  final int publicHolidays;
  final int schoolHolidays;
  final List<UpcomingHoliday> upcomingHolidaysList;

  HolidayStatistics({
    required this.totalHolidays,
    required this.upcomingHolidays,
    required this.publicHolidays,
    required this.schoolHolidays,
    required this.upcomingHolidaysList,
  });

  factory HolidayStatistics.fromJson(Map<String, dynamic> json) {
    return HolidayStatistics(
      totalHolidays: json['totalHolidays'] ?? 0,
      upcomingHolidays: json['upcomingHolidays'] ?? 0,
      publicHolidays: json['publicHolidays'] ?? 0,
      schoolHolidays: json['schoolHolidays'] ?? 0,
      upcomingHolidaysList: (json['upcomingHolidaysList'] as List<dynamic>?)
          ?.map((item) => UpcomingHoliday.fromJson(item))
          .toList() ?? [],
    );
  }
}

class UpcomingHoliday {
  final int id;
  final String name;
  final String date;
  final String description;
  final bool isPublicHoliday;
  final int daysUntilHoliday;

  UpcomingHoliday({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.isPublicHoliday,
    required this.daysUntilHoliday,
  });

  factory UpcomingHoliday.fromJson(Map<String, dynamic> json) {
    return UpcomingHoliday(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      isPublicHoliday: json['isPublicHoliday'] ?? false,
      daysUntilHoliday: json['daysUntilHoliday'] ?? 0,
    );
  }
}