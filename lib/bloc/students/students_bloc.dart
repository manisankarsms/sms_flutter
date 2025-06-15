// bloc/students/students_bloc.dart
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
    // on<SaveStudentMarks>(_onSaveStudentMarks);
    // on<RefreshStudents>(_onRefreshStudents);
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

  // Add these new handlers
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

  /*Future<void> _onSaveStudentMarks(
      SaveStudentMarks event,
      Emitter<StudentsState> emit,
      ) async {
    // Keep the current state to restore it after save operation
    final currentState = state;

    try {
      emit(StudentsLoading());
      await repository.saveStudentMarks(event.payload);

      // After successful save, if we were in a MarksLoaded state, reload the marks
      if (currentState is MarksLoaded) {
        final payload = event.payload;
        final marks = await repository.getStudentMarks(
          payload['classId'] as String,
          payload['examId'] as String,
          payload['subjectId'] as String,
        );
        emit(MarksLoaded(marks, payload['examId'] as String));
      } else {
        // Otherwise just restore the previous state
        emit(currentState);
      }
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }*/
}