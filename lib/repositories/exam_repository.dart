// lib/repositories/exam_repository.dart

import 'dart:convert';
import '../models/exams.dart';
import '../services/web_service.dart';

class ExamRepository {
  final WebService webService;
  final String endpoint = 'exams';

  ExamRepository({required this.webService});

  Future<List<Exam>> getExams() async {
    final response = await webService.fetchData(endpoint);
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  Future<Exam> getExamById(String id) async {
    final response = await webService.fetchData('$endpoint/$id');
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }

  Future<Exam> createExam(Exam exam) async {
    final examJson = jsonEncode(exam.toJson());
    final response = await webService.postData(endpoint, examJson);
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }

  Future<Exam> updateExam(Exam exam) async {
    if (exam.id == null) {
      throw Exception('Cannot update an exam without an ID');
    }
    final examJson = jsonEncode(exam.toJson());
    final response = await webService.putData('$endpoint/${exam.id}', examJson);
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }

  Future<void> deleteExam(String id) async {
    await webService.deleteData('$endpoint/$id');
  }

  Future<List<Exam>> getExamsByClassId(String classId) async {
    final response = await webService.fetchData('$endpoint?classId=$classId');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  Future<List<Exam>> getExamsBySubjectId(String subjectId) async {
    final response = await webService.fetchData('$endpoint?subjectId=$subjectId');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  Future<Exam> publishExam(String id) async {
    final response = await webService.putData('$endpoint/$id/publish', '{}');
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }
}