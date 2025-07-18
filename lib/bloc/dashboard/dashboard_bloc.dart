import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData); // Use correct name here
    // Add if implementing refresh
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
      try {
        final dashboardData = await repository.fetchDashboardData();
        emit(DashboardLoaded(dashboardData));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }
}
