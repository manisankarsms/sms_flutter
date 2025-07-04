import 'package:equatable/equatable.dart';
import '../../models/exams.dart';
import '../../models/student.dart';
import '../../models/student_marks.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object> get props => [];
}

class StudentsInitial extends StudentsState {}

class StudentsLoading extends StudentsState {}

class StudentsLoaded extends StudentsState {
  final List<Student> students;

  const StudentsLoaded(this.students);

  @override
  List<Object> get props => [students];
}

class StudentsError extends StudentsState {
  final String message;

  const StudentsError(this.message);

  @override
  List<Object> get props => [message];
}

class ExamsLoaded extends StudentsState {
  final List<Exam> exams;

  ExamsLoaded(this.exams);
}

class MarksLoaded extends StudentsState {
  final String examId;
  final List<StudentMark> marks;

  MarksLoaded(this.examId, this.marks);
}

class NoStudentsFound extends StudentsState {}

class MarksSaving extends StudentsState {}

class MarksSaved extends StudentsState {}

class AttendanceSubmitting extends StudentsState {}

class AttendanceSubmitted extends StudentsState {
  final String message;

  const AttendanceSubmitted(this.message);

  @override
  List<Object> get props => [message];
}

class AttendanceSubmissionError extends StudentsState {
  final String message;

  const AttendanceSubmissionError(this.message);

  @override
  List<Object> get props => [message];
}