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
      final response = await webService.fetchData('attendance/class/$classId/date/$date');

      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> attendanceJson = responseData["data"] ?? [];

      // Convert attendance response into Student objects
      return attendanceJson.map((json) {
        return Student(
          studentId: json['studentId'] ?? '',
          firstName: json['studentName'] ?? '',
          lastName: '',
          dateOfBirth: '',
          gender: '',
          mobileNumber: '',
          email: json['studentEmail'] ?? '',
          address: '',
          attendanceStatus: json['status'] ?? '',
          studentStandard: '${json['className'] ?? ''} ${json['sectionName'] ?? ''}'.trim(),
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch attendance: ${error.toString()}');
    }
  }

  // Submit attendance data
  Future<bool> submitAttendance(String classId, String date, Map<String, String> attendanceMap) async {
    try {
      final attendanceRecords = attendanceMap.entries.map((entry) {
        return {
          "studentId": entry.key,
          "status": entry.value.toUpperCase(), // Convert to uppercase (PRESENT, ABSENT, etc.)
        };
      }).toList();

      final requestBody = jsonEncode({
        "classId": classId,
        "date": date,
        "attendanceRecords": attendanceRecords,
      });

      final response = await webService.postData('attendance/bulk', requestBody);
      final Map<String, dynamic> responseData = jsonDecode(response);

      return responseData['success'] == true;
    } catch (error) {
      throw Exception('Failed to submit attendance: ${error.toString()}');
    }
  }

  Future<List<Exam>> getExams(String classId, String subjectId) async {
    try {
      final responseString = await webService.fetchData('${ApiEndpoints.exams}/class/$classId/subject/$subjectId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch exams');
      }

      final List<dynamic> examsJson = response['data'];
      return examsJson.map((json) => Exam.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch exams: ${error.toString()}');
    }
  }


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

      final response = await webService.fetchData('exam-results/exam/$examId');

      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> marksJson = responseData['marks'] ?? [];

      return marksJson.map((json) => StudentMark.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch student marks: ${error.toString()}');
    }
  }
}