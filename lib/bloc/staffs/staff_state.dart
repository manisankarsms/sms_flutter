import 'package:equatable/equatable.dart';
import '../../models/staff.dart';
import '../../models/user.dart';

enum StaffsStatus { initial, loading, success, failure }

class StaffsState extends Equatable {
  final StaffsStatus status;
  final List<User> staff;
  final List<User> filteredStaffs; // Add this

  StaffsState({
    this.status = StaffsStatus.initial,
    this.staff = const [],
    this.filteredStaffs = const [],
  });

  StaffsState copyWith({
    StaffsStatus? status,
    List<User>? staff,
    List<User>? filteredStaffs,
  }) {
    return StaffsState(
      status: status ?? this.status,
      staff: staff ?? this.staff,
      filteredStaffs: filteredStaffs ?? this.filteredStaffs,
    );
  }

  @override
  List<Object?> get props => [status, staff, filteredStaffs];
}
