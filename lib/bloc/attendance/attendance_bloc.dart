import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/repositories/attendance_repository.dart';
import 'package:sms/repositories/mock_repository.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(AttendanceInitial()) {
    on<FetchAttendance>(_onFetchAttendance);
  }

  void _onFetchAttendance(FetchAttendance event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final attendance = await repository.fetchAttendance(event.user.id);
      emit(AttendanceLoaded(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: e.toString()));
    }
  }
}
