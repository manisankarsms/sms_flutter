import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../services/request.dart';
import '../services/web_service.dart'; // Import your WebService class

class StudentRepository {
  final WebService webService;

  StudentRepository({required this.webService});

  Future<void> saveStudent(Student student) async {
    try {
      String request = frameAddStudentRequest(student);
      if (kDebugMode) {
        print("Request Payload: $request");
      }
      final response = await webService.postData('api/students', request);

      if (kDebugMode) {
        print("Response: $response");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error saving student: $error");
      }
      rethrow;
    }
  }

// Additional student-related methods like updateStudent, deleteStudent, fetchStudents can be added here.
}
