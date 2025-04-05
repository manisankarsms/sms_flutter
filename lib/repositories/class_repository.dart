import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/class.dart';
import '../services/web_service.dart';

class ClassRepository {
  final WebService webService;

  ClassRepository({required this.webService});

  Future<List<Class>> fetchClasses(String id) async {
    try {
      final requestBody = jsonEncode({'id': id});
      final String responseString = await webService.postData('classes', requestBody);
      if (kDebugMode) {
        print("API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString); // Parse JSON here
      final List<dynamic> classesJson = response['classes'];
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching classes: $e");
      }
      throw Exception('Failed to fetch classes: $e');
    }
  }

  Future<void> addClass(Class newClass) async {
    try {
      final requestBody = jsonEncode(newClass.toJson());
      await webService.postData('add_class', requestBody);
    } catch (e) {
      if (kDebugMode) {
        print("Error adding class: $e");
      }
      throw Exception('Failed to add class: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      final requestBody = jsonEncode({'class_id': classId});
      await webService.postData('delete_class', requestBody);
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting class: $e");
      }
      throw Exception('Failed to delete class: $e');
    }
  }

  Future<void> updateClass(Class updatedClass) async {
    try {
      final requestBody = jsonEncode(updatedClass.toJson());
      await webService.postData('update_class', requestBody);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating class: $e");
      }
      throw Exception('Failed to update class: $e');
    }
  }

  // Add new methods to fetch staff and subjects
  Future<List<Map<String, dynamic>>> fetchStaff() async {
    try {
      final String responseString = await webService.fetchData('admin/staffs');
      return List<Map<String, dynamic>>.from(jsonDecode(responseString));
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching staff: $e");
      }
      throw Exception('Failed to fetch staff: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    try {
      final String responseString = await webService.fetchData('subjects');
      final Map<String, dynamic> response = jsonDecode(responseString);
      return List<Map<String, dynamic>>.from(response['subjects']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching subjects: $e");
      }
      throw Exception('Failed to fetch subjects: $e');
    }
  }
}