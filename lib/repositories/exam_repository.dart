// lib/repositories/exam_repository.dart

import 'dart:convert';
import 'package:sms/utils/constants.dart';

import '../models/exams.dart';
import '../services/web_service.dart';

class ExamRepository {
  final WebService webService;

  ExamRepository({required this.webService});

  Future<List<Exam>> getExams() async {
    final response = await webService.fetchData(ApiEndpoints.exams);
    final Map<String, dynamic> json = jsonDecode(response);

    if (json['success'] == true && json['data'] is List) {
      final List<dynamic> data = json['data'];
      return data.map((item) => Exam.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load exams');
    }
  }


  Future<Exam> getExamById(String id) async {
    final response = await webService.fetchData('${ApiEndpoints.exams}/$id');
    final Map<String, dynamic> json = jsonDecode(response);

    if (json['success'] == true && json['data'] != null) {
      return Exam.fromJson(json['data']);
    } else {
      throw Exception('Failed to load exam details');
    }
  }


  Future<Exam> createExam(Exam exam) async {
    final examJson = jsonEncode(exam.toJson());
    final response = await webService.postData(ApiEndpoints.exams, examJson);
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }

  Future<Exam> updateExam(Exam exam) async {
    if (exam.id == null) {
      throw Exception('Cannot update an exam without an ID');
    }
    final examJson = jsonEncode(exam.toJson());
    final response = await webService.putData('${ApiEndpoints.exams}/${exam.id}', examJson);
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }

  Future<void> deleteExam(String id) async {
    await webService.deleteData('${ApiEndpoints.exams}/$id');
  }

  Future<List<Exam>> getExamsByClassId(String classId) async {
    final response = await webService.fetchData('${ApiEndpoints.exams}?classId=$classId');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  Future<List<Exam>> getExamsBySubjectId(String subjectId) async {
    final response = await webService.fetchData('${ApiEndpoints.exams}?subjectId=$subjectId');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Exam.fromJson(json)).toList();
  }

  Future<Exam> publishExam(String id) async {
    final response = await webService.putData('${ApiEndpoints.exams}/$id/publish', '{}');
    final Map<String, dynamic> data = jsonDecode(response);
    return Exam.fromJson(data);
  }
}