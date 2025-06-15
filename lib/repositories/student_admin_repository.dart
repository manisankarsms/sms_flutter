import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentAdminRepository {
  final WebService webService;

  StudentAdminRepository({required this.webService});

  Future<List<User>> fetchUsers() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.adminStudents);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch users');
      }

      final List<dynamic> usersJson = response['data'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users: $e");
      }
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<Class>> fetchClasses() async {
    try {
      final String responseString = await webService.fetchData('classes');
      if (kDebugMode) {
        print("API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);
      final List<dynamic> classesJson = response['data'];
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching classes: $e");
      }
      throw Exception('Failed to fetch classes: $e');
    }
  }

  Future<void> addUser(User newUser) async {
    try {
      final String userJson = jsonEncode(newUser.toJson());
      final responseString = await webService.postData(ApiEndpoints.studentAdmission, userJson);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to add user');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding user: $e");
      }
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final String userJson = jsonEncode(user.toJson());
      final responseString = await webService.putData('users/${user.id}', userJson);

      if (kDebugMode) {
        print("Update User API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user: $e");
      }
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final responseString = await webService.deleteData('users/$userId');

      if (kDebugMode) {
        print("Delete User API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting user: $e");
      }
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Assign a subject to a class
  Future<void> assignStudentToClass(String classId,String studentId) async {
    try {
      if (kDebugMode) print("Assigning student $studentId to class $classId");

      final requestBody = jsonEncode({
        'classId': classId,
        'studentId': studentId
      });

      await webService.postData('student-assignments', requestBody);

      if (kDebugMode) print("Student assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning student to class: $e");
      throw Exception('Failed to assign student to class: $e');
    }
  }
}