import '../../models/student_dashboard_model.dart';

abstract class StudentDashboardState {}

class StudentDashboardInitial extends StudentDashboardState {}

class StudentDashboardLoading extends StudentDashboardState {}

class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboardModel data;

  StudentDashboardLoaded(this.data);
}

class StudentDashboardError extends StudentDashboardState {
  final String message;

  StudentDashboardError(this.message);
}

class StudentDashboardRefreshing extends StudentDashboardState {
  final StudentDashboardModel data;

  StudentDashboardRefreshing(this.data);
}