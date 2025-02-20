// students_event.dart

import 'package:equatable/equatable.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object> get props => [];
}

class LoadStudents extends StudentsEvent {
  final String standard;

  const LoadStudents(this.standard);

  @override
  List<Object> get props => [standard];
}


class RefreshStudents extends StudentsEvent {
  final String standard;

  const RefreshStudents(this.standard);

  @override
  List<Object> get props => [standard];
}