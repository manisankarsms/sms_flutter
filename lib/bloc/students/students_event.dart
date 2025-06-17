// students_event.dart

import 'package:equatable/equatable.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object> get props => [];
}

class LoadStudents extends StudentsEvent {
  final String classId;
  final String userRole; // Add userRole to decide the endpoint
  final String date;
  const LoadStudents(this.classId, this.userRole, this.date);
}



class RefreshStudents extends StudentsEvent {
  final String standard;

  const RefreshStudents(this.standard);

  @override
  List<Object> get props => [standard];
}

class LoadStudentMarks extends StudentsEvent {
  final String classId;
  final String examId;
  final String subjectId;

  LoadStudentMarks(this.classId, this.examId, this.subjectId);
}

class LoadExams extends StudentsEvent {
  final String classId;

  LoadExams(this.classId);
}

class SaveStudentMarks extends StudentsEvent {
  final Map<String, dynamic> payload;

  SaveStudentMarks(this.payload);
}

class SubmitAttendance extends StudentsEvent {
  final String classId;
  final String date;
  final Map<String, String> attendanceMap;

  const SubmitAttendance(this.classId, this.date, this.attendanceMap);

  @override
  List<Object> get props => [classId, date, attendanceMap];
}