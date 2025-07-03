import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/student_dashboard/student_dashboard_event.dart';
import 'package:sms/bloc/student_dashboard/student_dashboard_state.dart';
import '../../repositories/student_dashboard_repository.dart';

class StudentDashboardBloc extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final StudentDashboardRepository repository;

  StudentDashboardBloc({required this.repository}) : super(StudentDashboardInitial()) {
    on<FetchStudentDashboardData>(_onFetchDashboardData);
    on<RefreshStudentDashboardData>(_onRefreshDashboardData);
    on<ResetStudentDashboard>(_onResetDashboard);
  }

  Future<void> _onFetchDashboardData(
      FetchStudentDashboardData event,
      Emitter<StudentDashboardState> emit,
      ) async {
    if (state is! StudentDashboardLoaded) {
      emit(StudentDashboardLoading());
    }

    try {
      final dashboardData = await repository.fetchDashboardData(event.id);
      emit(StudentDashboardLoaded(dashboardData));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboardData(
      RefreshStudentDashboardData event,
      Emitter<StudentDashboardState> emit,
      ) async {
    if (state is StudentDashboardLoaded) {
      emit(StudentDashboardRefreshing((state as StudentDashboardLoaded).data));
    }

    try {
      final dashboardData = await repository.fetchDashboardData(event.id);
      emit(StudentDashboardLoaded(dashboardData));
    } catch (e) {
      // If refresh fails and we had previous data, show error but keep data
      if (state is StudentDashboardRefreshing) {
        emit(StudentDashboardLoaded((state as StudentDashboardRefreshing).data));
      } else {
        emit(StudentDashboardError(e.toString()));
      }
    }
  }

  void _onResetDashboard(
      ResetStudentDashboard event,
      Emitter<StudentDashboardState> emit,
      ) {
    emit(StudentDashboardInitial());
  }
}