import 'package:equatable/equatable.dart';

import '../../models/student.dart';

abstract class StudentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveStudentEvent extends StudentEvent {
  final Map<String, dynamic> formData;

  SaveStudentEvent(this.formData);

  @override
  List<Object?> get props => [formData];
}