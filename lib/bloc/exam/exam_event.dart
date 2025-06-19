// lib/blocs/exam/exam_event.dart

import 'package:equatable/equatable.dart';
import '../../models/exams.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

class LoadExams extends ExamEvent {}

class LoadExamsByClass extends ExamEvent {
  final String classId;

  const LoadExamsByClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadExamsBySubject extends ExamEvent {
  final String subjectId;

  const LoadExamsBySubject(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class LoadExam extends ExamEvent {
  final String id;

  const LoadExam(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateExam extends ExamEvent {
  final Exam exam;

  const CreateExam(this.exam);

  @override
  List<Object?> get props => [exam];
}

class UpdateExam extends ExamEvent {
  final Exam exam;

  const UpdateExam(this.exam);

  @override
  List<Object?> get props => [exam];
}

class DeleteExam extends ExamEvent {
  final String id;

  const DeleteExam(this.id);

  @override
  List<Object?> get props => [id];
}

class PublishExam extends ExamEvent {
  final String id;

  const PublishExam(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadClassesByExamName extends ExamEvent {
  final String examName;

  const LoadClassesByExamName(this.examName);

  @override
  List<Object?> get props => [examName];
}

class LoadExamsByClassesAndExamsName extends ExamEvent {
  final String examName;
  final String classId;

  const LoadExamsByClassesAndExamsName(this.examName, this.classId);

  @override
  List<Object?> get props => [examName];
}

// NEW EVENTS FOR CLASSES AND SUBJECTS
class LoadAllClasses extends ExamEvent {}

class LoadAllSubjects extends ExamEvent {}