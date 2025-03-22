import 'package:bloc/bloc.dart';

import '../../repositories/student_repository.dart';
import 'new_student_event.dart';
import 'new_student_state.dart';

import 'package:bloc/bloc.dart';

import '../../repositories/student_repository.dart';
import 'new_student_event.dart';
import 'new_student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository studentRepository;

  StudentBloc({required this.studentRepository}) : super(StudentInitial()) {
    on<SaveStudentEvent>(_onSaveStudent);
  }

  Future<void> _onSaveStudent(
      SaveStudentEvent event,
      Emitter<StudentState> emit,
      ) async {
    emit(StudentSaving());
    try {
      final success = await studentRepository.submitStudentAdmission(event.formData);
      if (success) {
        emit(StudentSaved());
      } else {
        emit(StudentError("Failed to save student: Server returned unsuccessful response"));
      }
    } catch (error) {
      emit(StudentError("Failed to save student: ${error.toString()}"));
    }
  }
}

