import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';

import '../models/class.dart';
import '../models/subject.dart';
import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart';

class ClassRepository {
  final WebService webService;

  ClassRepository({required this.webService});

  Future<List<Class>> fetchAllClasses() async {
    try {
      final String responseString = await webService.fetchData('classes');
      if (kDebugMode) {
        print("API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString); // Parse JSON here
      final List<dynamic> classesJson = response['data'];
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching classes: $e");
      }
      throw Exception('Failed to fetch classes: $e');
    }
  }

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
      String request = frameAddClassRequest(newClass);
      await webService.postData('classes', request);
    } catch (e) {
      if (kDebugMode) {
        print("Error adding class: $e");
      }
      throw Exception('Failed to add class: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await webService.deleteData('classes/${classId}');
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
      await webService.putData('classes', requestBody);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating class: $e");
      }
      throw Exception('Failed to update class: $e');
    }
  }

  // Add new methods to fetch staff and subjects
  Future<List<User>> fetchStaff() async {
    if (kDebugMode) print("Fetching staff list...");

    try {
      final response = await webService.fetchData(ApiEndpoints.staffUsers);
      final Map<String, dynamic> responseJson = jsonDecode(response); // Parse JSON here
      final List<dynamic> classesJson = responseJson['data'];
      return classesJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print("Error fetching staff: $e");
      throw Exception('Failed to fetch staff: $e');
    }
  }

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

  //staff part

  Future<Map<String, dynamic>> fetchStaffClasses(String userId) async {
    try {
      final requestBody = jsonEncode({'id': userId});
      final String responseString = await webService.postData('staff/classes', requestBody);

      if (kDebugMode) {
        print("Staff classes API response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);

      // You can validate or transform here if needed
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching staff classes: $e");
      }
      throw Exception('Failed to fetch staff classes: $e');
    }
  }

}