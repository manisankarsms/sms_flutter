// lib/blocs/exam/exam_state.dart

import 'package:equatable/equatable.dart';
import '../../models/class.dart';
import '../../models/exams.dart';
import '../../models/subject.dart';

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

class ExamNamesLoaded extends ExamState {
  final List<String> examNames;

  const ExamNamesLoaded(this.examNames);

  @override
  List<Object?> get props => [examNames];
}

class ClassesLoaded extends ExamState {
  final String examName;
  final List<Class> classes;

  const ClassesLoaded(this.examName, this.classes);

  @override
  List<Object?> get props => [examName, classes];
}

class ExamsByClassExamNameLoaded extends ExamState {
  final List<Exam> exams;

  const ExamsByClassExamNameLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

class AllClassesLoaded extends ExamState {
  final List<Class> classes;
  AllClassesLoaded(this.classes);
}

class AllSubjectsLoaded extends ExamState {
  final List<Subject> subjects;
  AllSubjectsLoaded(this.subjects);
}

class ClassesAndSubjectsLoaded extends ExamState {
  final List<Class> classes;
  final List<Subject> subjects;
  ClassesAndSubjectsLoaded(this.classes, this.subjects);
}
