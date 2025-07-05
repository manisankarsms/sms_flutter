import 'dart:convert';

import '../models/complete_marks_model.dart';
import '../models/exams.dart';
import '../models/student.dart';
import '../models/student_marks.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class CompleteMarksRepository {
  final WebService webService;

  CompleteMarksRepository({required this.webService});

  Future<List<String>> getExamNames(String classId) async {
    final response = await webService.fetchData(ApiEndpoints.examsByName);
    final Map<String, dynamic> json = jsonDecode(response);

    if (json['success'] == true && json['data'] is List) {
      final List<dynamic> data = json['data'];
      return data.map((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load exam names');
    }
  }


  Future<CompleteMarksData> getCompleteMarks(
      String classId,
      String examName,
      ) async {
    try {
      final response = await webService.fetchData('exam-results/report/exam-name/$examName/class/$classId');
      final Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to fetch student marks');
      }

      final marksJson = responseData['data']; // this is a Map, not a List

      return CompleteMarksData.fromJson(marksJson);
    } catch (error) {
      throw Exception('Failed to fetch student marks: ${error.toString()}');
    }
  }

}