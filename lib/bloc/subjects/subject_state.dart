import 'package:equatable/equatable.dart';
import '../../models/subject.dart';

abstract class SubjectState extends Equatable {
  @override
  List<Object> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  SubjectLoaded(this.subjects);

  @override
  List<Object> get props => [subjects];
}

class SubjectError extends SubjectState {
  final String message;
  SubjectError(this.message);

  @override
  List<Object> get props => [message];
}
