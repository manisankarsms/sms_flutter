// repository/class_repository.dart
import 'dart:convert';

import '../models/class.dart';
import '../services/web_service.dart';

class ClassRepository {
  final WebService webService;

  ClassRepository({required this.webService});

  Future<List<Class>> fetchClasses(String id) async {
    try {
      final requestBody = jsonEncode({'id': id});
      final String responseString = await webService.postData('classes', requestBody);
      print("API Response: $responseString"); // Debugging

      final Map<String, dynamic> response = jsonDecode(responseString); // Parse JSON here
      final List<dynamic> classesJson = response['classes'];
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching classes: $e"); // Debugging
      throw Exception('Failed to fetch classes: $e');
    }
  }


  /*Future<void> addClass(Class newClass) async {
    try {
      await webService.postData('classes', newClass.toJson());
    } catch (e) {
      throw Exception('Failed to add class: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await webService.deleteData('classes/$classId');
    } catch (e) {
      throw Exception('Failed to delete class: $e');
    }
  }
}*/

  Future<void> addClass(Class newClass) async {
    // Simulate adding a class to a database
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> deleteClass(String classId) async {
    // Simulate deleting a class from a database
    await Future.delayed(Duration(seconds: 1));
  }
}
