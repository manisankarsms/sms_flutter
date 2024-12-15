import 'package:equatable/equatable.dart';
import 'package:sms/models/attendance.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendance;

  AttendanceLoaded({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError({required this.message});

  @override
  List<Object> get props => [message];
}
