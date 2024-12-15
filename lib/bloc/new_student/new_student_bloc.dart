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
      await studentRepository.saveStudent(event.student);
      emit(StudentSaved());
    } catch (error) {
      emit(StudentError("Failed to save student: ${error.toString()}"));
    }
  }
}

