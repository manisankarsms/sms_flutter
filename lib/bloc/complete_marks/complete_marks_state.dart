import '../../models/complete_marks_model.dart';

abstract class CompleteMarksState {}

class CompleteMarksInitial extends CompleteMarksState {}

class CompleteMarksLoading extends CompleteMarksState {}

class ExamNamesLoaded extends CompleteMarksState {
  final List<String> examNames;

  ExamNamesLoaded(this.examNames);
}

class CompleteMarksLoaded extends CompleteMarksState {
  final CompleteMarksData marksData;

  CompleteMarksLoaded(this.marksData);
}

class NoMarksFound extends CompleteMarksState {}

class CompleteMarksError extends CompleteMarksState {
  final String message;

  CompleteMarksError(this.message);
}