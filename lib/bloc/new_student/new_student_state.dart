abstract class StudentState {}

class StudentInitialState extends StudentState {}

class StudentLoadingState extends StudentState {}

class StudentSuccessState extends StudentState {
  final String message;
  final dynamic data;

  StudentSuccessState({required this.message, this.data});

  @override
  String toString() => 'StudentSuccessState { message: $message }';
}

class StudentErrorState extends StudentState {
  final String message;
  final String? error;

  StudentErrorState({required this.message, this.error});

  @override
  String toString() => 'StudentErrorState { message: $message, error: $error }';
}

// Add these new states for bulk upload:
class BulkStudentProgressState extends StudentState {
  final int processed;
  final int total;

  BulkStudentProgressState(this.processed, this.total);

  @override
  String toString() => 'BulkStudentProgressState { processed: $processed, total: $total }';
}

class BulkStudentSuccessState extends StudentState {
  final int successCount;
  final int failedCount;
  final List<String> failedStudents;
  final List<String> duplicateEmails;
  final List<String> duplicateMobiles;

  BulkStudentSuccessState({
    required this.successCount,
    required this.failedCount,
    this.failedStudents = const [],
    this.duplicateEmails = const [],
    this.duplicateMobiles = const [],
  });

  @override
  String toString() => 'BulkStudentSuccessState { success: $successCount, failed: $failedCount }';
}