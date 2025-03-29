import 'package:equatable/equatable.dart';

abstract class StaffRegistrationEvent extends Equatable {
  const StaffRegistrationEvent();

  @override
  List<Object> get props => [];
}

class SubmitStaffRegistrationEvent extends StaffRegistrationEvent {
  final Map<String, dynamic> staffData;

  const SubmitStaffRegistrationEvent(this.staffData);

  @override
  List<Object> get props => [staffData];
}