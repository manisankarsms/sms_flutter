abstract class StudentEvent {}

class SaveStudentEvent extends StudentEvent {
  final Map<String, dynamic> formData;
  SaveStudentEvent(this.formData);
}

// Add this new event for bulk upload:
class BulkSaveStudentsEvent extends StudentEvent {
  final List<Map<String, dynamic>> studentsData;

  BulkSaveStudentsEvent(this.studentsData);

  @override
  String toString() => 'BulkSaveStudentsEvent { studentsCount: ${studentsData.length} }';
}