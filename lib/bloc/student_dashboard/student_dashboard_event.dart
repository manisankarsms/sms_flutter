abstract class StudentDashboardEvent {}

class FetchStudentDashboardData extends StudentDashboardEvent {
  final String id;
  FetchStudentDashboardData(this.id);
}

class RefreshStudentDashboardData extends StudentDashboardEvent {
  final String id;
  RefreshStudentDashboardData(this.id);
}

class ResetStudentDashboard extends StudentDashboardEvent {}