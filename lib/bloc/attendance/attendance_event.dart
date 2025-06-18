import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchAttendance extends AttendanceEvent {
  User user;
  FetchAttendance(this.user);
}
