import 'package:equatable/equatable.dart';

abstract class StaffClassesEvent extends Equatable {
  const StaffClassesEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffClasses extends StaffClassesEvent {
  final String staffId;

  const LoadStaffClasses({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}
