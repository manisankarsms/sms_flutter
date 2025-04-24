class DashboardModel {
  final Students students;
  final Staff staff;
  final Complaints complaints;
  final PlanUsage planUsage;

  DashboardModel({
    required this.students,
    required this.staff,
    required this.complaints,
    required this.planUsage,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      students: Students.fromJson(json['students']),
      staff: Staff.fromJson(json['staff']),
      complaints: Complaints.fromJson(json['complaints']),
      planUsage: PlanUsage.fromJson(json['planUsage']),
    );
  }
}

class Students {
  final String totalCount;
  final String activeCount;
  final String newAdmissionsThisMonth;
  final GenderDistribution genderDistribution;

  Students({
    required this.totalCount,
    required this.activeCount,
    required this.newAdmissionsThisMonth,
    required this.genderDistribution,
  });

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      totalCount: json['totalCount'].toString(),
      activeCount: json['activeCount'].toString(),
      newAdmissionsThisMonth: json['newAdmissionsThisMonth'].toString(),
      genderDistribution: GenderDistribution.fromJson(json['genderDistribution']),
    );
  }
}

class GenderDistribution {
  final String boys;
  final String girls;
  final String other;

  GenderDistribution({
    required this.boys,
    required this.girls,
    required this.other,
  });

  factory GenderDistribution.fromJson(Map<String, dynamic> json) {
    return GenderDistribution(
      boys: json['boys'].toString(),
      girls: json['girls'].toString(),
      other: json['other'].toString(),
    );
  }
}

class Staff {
  final String totalTeachers;
  final String totalAdminStaff;
  final String onLeaveToday;

  Staff({
    required this.totalTeachers,
    required this.totalAdminStaff,
    required this.onLeaveToday,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      totalTeachers: json['totalTeachers'].toString(),
      totalAdminStaff: json['totalAdminStaff'].toString(),
      onLeaveToday: json['onLeaveToday'].toString(),
    );
  }
}

class Complaints {
  final String totalCount;
  final ComplaintsByStatus byStatus;
  final String resolutionRate;

  Complaints({
    required this.totalCount,
    required this.byStatus,
    required this.resolutionRate,
  });

  factory Complaints.fromJson(Map<String, dynamic> json) {
    return Complaints(
      totalCount: json['totalCount'].toString(),
      byStatus: ComplaintsByStatus.fromJson(json['byStatus']),
      resolutionRate: json['resolutionRate'].toString(),
    );
  }
}

class ComplaintsByStatus {
  final String open;
  final String pending;
  final String resolved;

  ComplaintsByStatus({
    required this.open,
    required this.pending,
    required this.resolved,
  });

  factory ComplaintsByStatus.fromJson(Map<String, dynamic> json) {
    return ComplaintsByStatus(
      open: json['open'].toString(),
      pending: json['pending'].toString(),
      resolved: json['resolved'].toString(),
    );
  }
}

class PlanUsage {
  final String planName;
  final String studentLimit;
  final String staffLimit;
  final String currentStudentCount;
  final String currentStaffCount;
  final String storageLimitMB;
  final String usedStorageMB;
  final String nextBillingDate;

  PlanUsage({
    required this.planName,
    required this.studentLimit,
    required this.staffLimit,
    required this.currentStudentCount,
    required this.currentStaffCount,
    required this.storageLimitMB,
    required this.usedStorageMB,
    required this.nextBillingDate,
  });

  factory PlanUsage.fromJson(Map<String, dynamic> json) {
    return PlanUsage(
      planName: json['planName'].toString(),
      studentLimit: json['studentLimit'].toString(),
      staffLimit: json['staffLimit'].toString(),
      currentStudentCount: json['currentStudentCount'].toString(),
      currentStaffCount: json['currentStaffCount'].toString(),
      storageLimitMB: json['storageLimitMB'].toString(),
      usedStorageMB: json['usedStorageMB'].toString(),
      nextBillingDate: json['nextBillingDate'].toString(),
    );
  }
}