// lib/blocs/exam/exam_state.dart

import 'package:equatable/equatable.dart';
import '../../models/exams.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamsLoaded extends ExamState {
  final List<Exam> exams;

  const ExamsLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

class ExamLoaded extends ExamState {
  final Exam exam;

  const ExamLoaded(this.exam);

  @override
  List<Object?> get props => [exam];
}

class ExamOperationSuccess extends ExamState {
  final String message;

  const ExamOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object?> get props => [message];
}