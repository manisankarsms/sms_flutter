// lib/blocs/exam/exam_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/exam_repository.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository examRepository;

  ExamBloc({required this.examRepository}) : super(ExamInitial()) {
    on<LoadExams>(_onLoadExams);
    on<LoadExamsByClass>(_onLoadExamsByClass);
    on<LoadExamsBySubject>(_onLoadExamsBySubject);
    on<LoadExam>(_onLoadExam);
    on<CreateExam>(_onCreateExam);
    on<UpdateExam>(_onUpdateExam);
    on<DeleteExam>(_onDeleteExam);
    on<PublishExam>(_onPublishExam);
    on<LoadClassesByExamName>(_onLoadClassesByExamName);
    on<LoadExamsByClassesAndExamsName>(_onLoadExamsByClassesAndExamsName);
    // NEW EVENT HANDLERS
    on<LoadAllClasses>(_onLoadAllClasses);
    on<LoadAllSubjects>(_onLoadAllSubjects);
  }

  void _onLoadExams(LoadExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final examNames = await examRepository.getExamNames(); // returns List<String>
      emit(ExamNamesLoaded(examNames));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onLoadClassesByExamName(LoadClassesByExamName event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final classes = await examRepository.getClassesByExamName(event.examName);
      emit(ClassesLoaded(event.examName, classes));
    } catch (e) {
      emit(ExamError('Failed to load classes: ${e.toString()}'));
    }
  }

  void _onLoadExamsByClassesAndExamsName(LoadExamsByClassesAndExamsName event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exams = await examRepository.getExamsByClassesAndExamName(event.examName, event.classId);
      emit(ExamsByClassExamNameLoaded(exams));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onLoadExamsByClass(LoadExamsByClass event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exams = await examRepository.getExamsByClassId(event.classId);
      emit(ExamsLoaded(exams));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onLoadExamsBySubject(LoadExamsBySubject event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exams = await examRepository.getExamsBySubjectId(event.subjectId);
      emit(ExamsLoaded(exams));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onLoadExam(LoadExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exam = await examRepository.getExamById(event.id);
      emit(ExamLoaded(exam));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onCreateExam(CreateExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exam = await examRepository.createExam(event.exam);

      // Only emit success state - don't emit ExamLoaded immediately
      emit(ExamOperationSuccess('Exam created successfully'));

      // Optionally, you can emit ExamLoaded after a small delay
      // or handle it in the UI listener instead

    } catch (e) {
      print('Create exam error: ${e.toString()}'); // Add logging
      emit(ExamError('Failed to create exam: ${e.toString()}'));
    }
  }

  void _onUpdateExam(UpdateExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exam = await examRepository.updateExam(event.exam);
      emit(ExamOperationSuccess('Exam updated successfully'));
      emit(ExamLoaded(exam));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onDeleteExam(DeleteExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      await examRepository.deleteExam(event.id);
      emit(ExamOperationSuccess('Exam deleted successfully'));
      add(LoadExams()); // Reload exams after deletion
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  void _onPublishExam(PublishExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exam = await examRepository.publishExam(event.id);
      emit(ExamOperationSuccess('Exam published successfully'));
      emit(ExamLoaded(exam));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  // NEW EVENT HANDLERS FOR CLASSES AND SUBJECTS
  void _onLoadAllClasses(LoadAllClasses event, Emitter<ExamState> emit) async {
    try {
      final classes = await examRepository.fetchAllClasses();
      emit(AllClassesLoaded(classes));
    } catch (e) {
      emit(ExamError('Failed to load classes: ${e.toString()}'));
    }
  }

  void _onLoadAllSubjects(LoadAllSubjects event, Emitter<ExamState> emit) async {
    try {
      final subjects = await examRepository.fetchSubjects();
      emit(AllSubjectsLoaded(subjects));
    } catch (e) {
      emit(ExamError('Failed to load subjects: ${e.toString()}'));
    }
  }

  // Helper method to load both classes and subjects together
  void loadClassesAndSubjects() async {
    emit(ExamLoading());
    try {
      final classes = await examRepository.fetchAllClasses();
      final subjects = await examRepository.fetchSubjects();
      emit(ClassesAndSubjectsLoaded(classes, subjects));
    } catch (e) {
      emit(ExamError('Failed to load classes and subjects: ${e.toString()}'));
    }
  }
}