// repository/class_repository.dart
import 'dart:convert';

import '../models/student.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentsRepository {
  final WebService webService;

  StudentsRepository({required this.webService});

  Future<List<Student>> getStudents(String classId) async {
    try {
      final requestBody = jsonEncode({'classId': classId});
      final response = await webService.postData(ApiEndpoints.adminStudents, requestBody);

      // Decode as a List, not a Map
      final List<dynamic> studentsJson = jsonDecode(response);
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch students: ${error.toString()}');
    }
  }
}

