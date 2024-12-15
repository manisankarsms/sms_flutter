import 'package:equatable/equatable.dart';

import '../../models/student.dart';

abstract class StudentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveStudentEvent extends StudentEvent {
  final Student student;

  SaveStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}
