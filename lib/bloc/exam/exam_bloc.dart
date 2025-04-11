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
  }

  void _onLoadExams(LoadExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exams = await examRepository.getExams();
      emit(ExamsLoaded(exams));
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
      emit(ExamOperationSuccess('Exam created successfully'));
      emit(ExamLoaded(exam));
    } catch (e) {
      emit(ExamError(e.toString()));
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
}