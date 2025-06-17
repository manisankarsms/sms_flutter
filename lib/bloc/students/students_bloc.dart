import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/utils/constants.dart';
import '../../models/student.dart';
import '../../models/exams.dart';
import '../../models/student_marks.dart';
import '../../repositories/students_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository repository;

  StudentsBloc({required this.repository}) : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadExams>(_onLoadExams);
    on<LoadStudentMarks>(_onLoadStudentMarks);
    on<SubmitAttendance>(_onSubmitAttendance); // Add this line
    on<RefreshStudents>(_onRefreshStudents); // Add this if not already present
  }

  Future<void> _onLoadStudents(
      LoadStudents event,
      Emitter<StudentsState> emit,
      ) async {
    emit(StudentsLoading());

    try {
      List<Student> students;

      if (event.userRole.toLowerCase() == Constants.admin) {
        students = await repository.getAdminStudents(event.classId);
      } else {
        students = await repository.getStaffAttendance(event.classId, event.date);
      }

      emit(StudentsLoaded(students));
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }

  Future<void> _onLoadExams(
      LoadExams event,
      Emitter<StudentsState> emit,
      ) async {
    try {
      final exams = await repository.getExams();
      emit(ExamsLoaded(exams));
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }

  Future<void> _onLoadStudentMarks(
      LoadStudentMarks event,
      Emitter<StudentsState> emit,
      ) async {
    emit(StudentsLoading());
    try {
      final marks = await repository.getStudentMarks(
        event.classId,
        event.examId,
        event.subjectId,
      );

      if (marks.isEmpty) {
        emit(NoStudentsFound());
      } else {
        emit(MarksLoaded(event.examId, marks));
      }
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }

  // Add this new handler
  Future<void> _onSubmitAttendance(
      SubmitAttendance event,
      Emitter<StudentsState> emit,
      ) async {
    emit(AttendanceSubmitting());

    try {
      final success = await repository.submitAttendance(
        event.classId,
        event.date,
        event.attendanceMap,
      );

      if (success) {
        emit(AttendanceSubmitted('Attendance submitted successfully!'));
      } else {
        emit(AttendanceSubmissionError('Failed to submit attendance'));
      }
    } catch (error) {
      emit(AttendanceSubmissionError(error.toString()));
    }
  }

  // Add this handler if RefreshStudents event exists
  Future<void> _onRefreshStudents(
      RefreshStudents event,
      Emitter<StudentsState> emit,
      ) async {
    emit(StudentsLoading());

    try {
      final students = await repository.getAdminStudents(event.standard);
      emit(StudentsLoaded(students));
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }
}