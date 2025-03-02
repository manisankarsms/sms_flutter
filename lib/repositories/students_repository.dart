// repository/class_repository.dart
import 'dart:convert';

import '../models/student.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentsRepository {
  final WebService webService;

  StudentsRepository({required this.webService});

  // Fetch students for Admin
  Future<List<Student>> getAdminStudents(String classId) async {
    try {
      final requestBody = jsonEncode({'classId': classId});
      final response = await webService.postData(ApiEndpoints.adminStudents, requestBody);

      final List<dynamic> studentsJson = jsonDecode(response);
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
          contactNumber: '',
          email: '',
          address: '',
          studentStandard: '',
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch attendance: ${error.toString()}');
    }
  }

}


