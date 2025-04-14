import 'package:equatable/equatable.dart';
import '../../models/class.dart';

enum StaffClassesStatus { initial, loading, success, failure }

class StaffClassesState extends Equatable {
  final StaffClassesStatus status;
  final List<Class> myClasses;
  final List<Class> teachingClasses;

  const StaffClassesState({
    this.status = StaffClassesStatus.initial,
    this.myClasses = const [],
    this.teachingClasses = const [],
  });

  StaffClassesState copyWith({
    StaffClassesStatus? status,
    List<Class>? myClasses,
    List<Class>? teachingClasses,
  }) {
    return StaffClassesState(
      status: status ?? this.status,
      myClasses: myClasses ?? this.myClasses,
      teachingClasses: teachingClasses ?? this.teachingClasses,
    );
  }

  @override
  List<Object?> get props => [status, myClasses, teachingClasses];
}
