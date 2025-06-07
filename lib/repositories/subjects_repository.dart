import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';
import '../models/subject.dart';
import '../services/web_service.dart';

class SubjectRepository {
  final WebService webService;

  SubjectRepository({required this.webService});

  Future<List<Subject>> fetchSubjects() async {
    try {
      final responseString = await webService.fetchData(ApiEndpoints.subjects);
      final Map<String, dynamic> response = jsonDecode(responseString); // Decode as Map
      final List<dynamic> subjectsJson = response['data']; // Extract subjects list
      return subjectsJson.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching subjects: $e");
      }
      throw Exception('Failed to fetch subjects: $e');
    }
  }

  Future<bool> addSubject(Subject subject) async {
    try {
      final responseString = await webService.postData(ApiEndpoints.subjects, jsonEncode(subject.toJson()));
      return responseString.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error adding subject: $e");
      }
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    try {
      final responseString = await webService.putData('${ApiEndpoints.subjects}/${subject.id}', jsonEncode(subject.toJson()));
      return responseString.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error updating subject: $e");
      }
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    try {
      final responseString = await webService.deleteData('subjects/$id');
      return responseString.isEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting subject: $e");
      }
      return false;
    }
  }
}

