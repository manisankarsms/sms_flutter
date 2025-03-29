import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/subjects_repository.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;

  SubjectBloc({required this.subjectRepository}) : super(SubjectInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<AddSubject>(_onAddSubject);
    on<UpdateSubject>(_onUpdateSubject);
    on<DeleteSubject>(_onDeleteSubject);

    add(LoadSubjects());
  }

  Future<void> _onLoadSubjects(
      LoadSubjects event, Emitter<SubjectState> emit) async {
    emit(SubjectLoading());
    try {
      final subjects = await subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(SubjectError('Failed to fetch subjects'));
    }
  }

  Future<void> _onAddSubject(
      AddSubject event, Emitter<SubjectState> emit) async {
    try {
      await subjectRepository.addSubject(event.subject);
      add(LoadSubjects());
    } catch (e) {
      emit(SubjectError('Failed to add subject'));
    }
  }

  Future<void> _onUpdateSubject(
      UpdateSubject event, Emitter<SubjectState> emit) async {
    try {
      await subjectRepository.updateSubject(event.subject);
      add(LoadSubjects());
    } catch (e) {
      emit(SubjectError('Failed to update subject'));
    }
  }

  Future<void> _onDeleteSubject(
      DeleteSubject event, Emitter<SubjectState> emit) async {
    try {
      await subjectRepository.deleteSubject(event.id);
      add(LoadSubjects());
    } catch (e) {
      emit(SubjectError('Failed to delete subject'));
    }
  }
}
