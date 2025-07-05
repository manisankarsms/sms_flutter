import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/complete_marks_repository.dart';
import 'complete_marks_event.dart';
import 'complete_marks_state.dart';

class CompleteMarksBloc extends Bloc<CompleteMarksEvent, CompleteMarksState> {
  final CompleteMarksRepository repository;

  CompleteMarksBloc({required this.repository}) : super(CompleteMarksInitial()) {
    on<LoadExamNames>(_onLoadExamNames);
    on<LoadCompleteMarks>(_onLoadCompleteMarks);
  }

  Future<void> _onLoadExamNames(
      LoadExamNames event,
      Emitter<CompleteMarksState> emit,
      ) async {
    emit(CompleteMarksLoading());

    try {
      final examNames = await repository.getExamNames(event.classId);
      emit(ExamNamesLoaded(examNames));
    } catch (error) {
      emit(CompleteMarksError(error.toString()));
    }
  }

  Future<void> _onLoadCompleteMarks(
      LoadCompleteMarks event,
      Emitter<CompleteMarksState> emit,
      ) async {
    emit(CompleteMarksLoading());

    try {
      final marksData = await repository.getCompleteMarks(
        event.classId,
        event.examName,
      );

      if (marksData.students.isEmpty) {
        emit(NoMarksFound());
      } else {
        emit(CompleteMarksLoaded(marksData));
      }
    } catch (error) {
      emit(CompleteMarksError(error.toString()));
    }
  }
}