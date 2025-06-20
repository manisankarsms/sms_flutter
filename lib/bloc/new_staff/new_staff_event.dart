import 'package:equatable/equatable.dart';

abstract class StaffRegistrationEvent extends Equatable {
  const StaffRegistrationEvent();

  @override
  List<Object> get props => [];
}

class SaveStaffEvent extends StaffRegistrationEvent {
  final Map<String, dynamic> formData;

  const SaveStaffEvent(this.formData);

  @override
  List<Object> get props => [formData];
}

class BulkSaveStaffEvent extends StaffRegistrationEvent {
  final List<Map<String, dynamic>> staffData;

  const BulkSaveStaffEvent(this.staffData);

  @override
  List<Object> get props => [staffData];
}