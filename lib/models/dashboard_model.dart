class DashboardModel {
  final Students students;
  final Staffs staff;

  DashboardModel({required this.students, required this.staff});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      students: Students.fromJson(json['students']),
      staff: Staffs.fromJson(json['staff']),
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
      totalCount: json['totalCount'],
      activeCount: json['activeCount'],
      newAdmissionsThisMonth: json['newAdmissionsThisMonth'],
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
      boys: json['boys'],
      girls: json['girls'],
      other: json['other'],
    );
  }
}

class Staffs {
  final String totalTeachers;
  final String totalAdminStaff;
  final String onLeaveToday;

  Staffs({
    required this.totalTeachers,
    required this.totalAdminStaff,
    required this.onLeaveToday,
  });

  factory Staffs.fromJson(Map<String, dynamic> json) {
    return Staffs(
      totalTeachers: json['totalTeachers'],
      totalAdminStaff: json['totalAdminStaff'],
      onLeaveToday: json['onLeaveToday'],
    );
  }
}
