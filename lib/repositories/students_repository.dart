// repository/class_repository.dart
import 'dart:convert';

import '../models/exams.dart';
import '../models/student.dart';
import '../models/student_marks.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentsRepository {
  final WebService webService;

  StudentsRepository({required this.webService});

  // Fetch students for Admin
  Future<List<Student>> getAdminStudents(String classId) async {
    try {
      final responseString = await webService.fetchData('${ApiEndpoints.adminStudentsClass}/$classId/students');

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch users');
      }

      final List<dynamic> studentsJson = response['data'];
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch students: ${error.toString()}');
    }
  }

  // Fetch attendance data for Staff
  Future<List<Student>> getStaffAttendance(String classId, String date) async {
    try {
      final requestBody = jsonEncode({'classId': classId, 'date': date});
      final response = await webService.postData(ApiEndpoints.staffAttendance, requestBody);

      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> attendanceJson = responseData["attendance"] ?? [];

      // Convert attendance response into Student objects
      return attendanceJson.map((json) {
        return Student(
          studentId: json['studentId'] ?? '',
          firstName: json['studentName'] ?? json['name'] ?? '', // Handle both cases
          lastName: '',
          dateOfBirth: '',
          gender: '',
          mobileNumber: '',
          email: '',
          address: '',
          studentStandard: '',
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch attendance: ${error.toString()}');
    }
  }

  Future<List<Exam>> getExams() async {
    final response = await webService.fetchData(ApiEndpoints.exams);
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  // Add these new methods
  Future<List<StudentMark>> getStudentMarks(
      String classId,
      String examId,
      String subjectId) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'examId': examId,
        'subjectId': subjectId,
      });

      final response = await webService.postData('students/marks', requestBody);

      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> marksJson = responseData['marks'] ?? [];

      return marksJson.map((json) => StudentMark.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch student marks: ${error.toString()}');
    }
  }

  /*Future<void> saveStudentMarks(Map<String, dynamic> payload) async {
    try {
      final requestBody = jsonEncode(payload);
      await webService.postData(ApiEndpoints.saveMarks, requestBody);
    } catch (error) {
      throw Exception('Failed to save student marks: ${error.toString()}');
    }
  }*/
}