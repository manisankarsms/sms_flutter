import 'package:equatable/equatable.dart';
import '../../models/staff.dart';

abstract class StaffsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStaff extends StaffsEvent {}

class AddStaff extends StaffsEvent {
  final Staff staff;

  AddStaff(this.staff);

  @override
  List<Object?> get props => [staff];
}

class DeleteStaff extends StaffsEvent {
  final String staffId;

  DeleteStaff(this.staffId);

  @override
  List<Object?> get props => [staffId];
}

class SearchStaffs extends StaffsEvent {
  final String query;

  SearchStaffs(this.query);

  @override
  List<Object?> get props => [query];
}

