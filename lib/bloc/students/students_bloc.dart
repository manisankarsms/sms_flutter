// bloc/students/students_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/students_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository repository;

  StudentsBloc({required this.repository}) : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<RefreshStudents>(_onRefreshStudents);
  }

  Future<void> _onLoadStudents(
      LoadStudents event,
      Emitter<StudentsState> emit,
      ) async {
    emit(StudentsLoading());

    try {
      final students = await repository.getStudents(event.standard);
      emit(StudentsLoaded(students));
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }

  Future<void> _onRefreshStudents(
      RefreshStudents event,
      Emitter<StudentsState> emit,
      ) async {
    try {
      final students = await repository.getStudents(event.standard);
      emit(StudentsLoaded(students));
    } catch (error) {
      emit(StudentsError(error.toString()));
    }
  }
}