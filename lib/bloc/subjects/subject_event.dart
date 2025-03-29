import 'package:equatable/equatable.dart';

import '../../models/subject.dart';

abstract class SubjectEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadSubjects extends SubjectEvent {}

class AddSubject extends SubjectEvent {
  final Subject subject;
  AddSubject(this.subject);

  @override
  List<Object> get props => [subject];
}

class UpdateSubject extends SubjectEvent {
  final Subject subject;
  UpdateSubject(this.subject);

  @override
  List<Object> get props => [subject];
}

class DeleteSubject extends SubjectEvent {
  final String id;
  DeleteSubject(this.id);

  @override
  List<Object> get props => [id];
}
