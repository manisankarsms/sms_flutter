abstract class CompleteMarksEvent {}

class LoadExamNames extends CompleteMarksEvent {
  final String classId;

  LoadExamNames(this.classId);
}

class LoadCompleteMarks extends CompleteMarksEvent {
  final String classId;
  final String examName;

  LoadCompleteMarks(this.classId, this.examName);
}