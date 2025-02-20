import 'package:equatable/equatable.dart';
import '../../models/staff.dart';

enum StaffsStatus { initial, loading, success, failure }

class StaffsState extends Equatable {
  final StaffsStatus status;
  final List<Staff> staff;
  final List<Staff> filteredStaffs; // Add this

  StaffsState({
    this.status = StaffsStatus.initial,
    this.staff = const [],
    this.filteredStaffs = const [],
  });

  StaffsState copyWith({
    StaffsStatus? status,
    List<Staff>? staff,
    List<Staff>? filteredStaffs,
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
