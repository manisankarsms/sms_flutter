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

  Future<List<Class>> fetchClasses(String id) async {
    try {
      final requestBody = jsonEncode({'id': id});
      final String responseString = await webService.postData(
          'classes', requestBody);
      if (kDebugMode) {
        print("API Response: $responseString");
      }

      final Map<String, dynamic> response = jsonDecode(responseString);
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

  // Staff and Subjects methods
  Future<List<User>> fetchStaff() async {
    if (kDebugMode) print("Fetching staff list...");

    try {
      final response = await webService.fetchData(ApiEndpoints.staffUsers);
      final Map<String, dynamic> responseJson = jsonDecode(response);
      final List<dynamic> staffJson = responseJson['data'];
      return staffJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print("Error fetching staff: $e");
      throw Exception('Failed to fetch staff: $e');
    }
  }

  Future<List<Subject>> fetchSubjects() async {
    try {
      final responseString = await webService.fetchData(ApiEndpoints.subjects);
      final Map<String, dynamic> response = jsonDecode(responseString);
      final List<dynamic> subjectsJson = response['data'];
      return subjectsJson.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching subjects: $e");
      }
      throw Exception('Failed to fetch subjects: $e');
    }
  }

  // Staff Class Assignment methods
  Future<List<dynamic>> getAllStaffClassAssignments() async {
    try {
      final response = await webService.fetchData(
          'api/v1/staff-class-assignments');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching staff class assignments: $e");
      throw Exception('Failed to fetch staff class assignments: $e');
    }
  }

  Future<List<dynamic>> getStaffClassAssignmentsForActiveYear() async {
    try {
      final response = await webService.fetchData(
          'api/v1/staff-class-assignments/active-year');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print(
          "Error fetching active year staff class assignments: $e");
      throw Exception(
          'Failed to fetch active year staff class assignments: $e');
    }
  }

  Future<List<dynamic>> getClassesByStaffForActiveYear(String staffId) async {
    try {
      final response = await webService.fetchData(
          'api/v1/staff-class-assignments/staff/$staffId/classes/active-year');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching classes by staff: $e");
      throw Exception('Failed to fetch classes by staff: $e');
    }
  }

  Future<List<dynamic>> getStaffByClassForActiveYear(String classId) async {
    try {
      final response = await webService.fetchData(
          'api/v1/staff-class-assignments/class/$classId/staff/active-year');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching staff by class: $e");
      throw Exception('Failed to fetch staff by class: $e');
    }
  }

  // Additional methods needed by the UI (Missing from original code)

  /// Get classes with their assigned staff for active year
  Future<List<dynamic>> getClassesWithStaffForActiveYear() async {
    try {
      final response = await webService.fetchData(
          'api/v1/staff-class-assignments/classes-with-staff/active-year');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching classes with staff: $e");
      throw Exception('Failed to fetch classes with staff: $e');
    }
  }

  /// Get classes with subject staff assignments for active year
  Future<List<dynamic>> getClassesWithSubjectStaffForActiveYear() async {
    try {
      final response = await webService.fetchData(
          'api/v1/subject-staff-assignments/classes-with-subject-staff/active-year');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching classes with subject staff: $e");
      throw Exception('Failed to fetch classes with subject staff: $e');
    }
  }

  /// Update class teacher assignments
  Future<void> updateClassTeacherAssignments(String classId,
      List<String> teacherIds) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'teacherIds': teacherIds,
      });

      await webService.putData(
          'api/v1/staff-class-assignments/class/$classId/teachers',
          requestBody);

      if (kDebugMode) print("Class teacher assignments updated successfully");
    } catch (e) {
      if (kDebugMode) print("Error updating class teacher assignments: $e");
      throw Exception('Failed to update class teacher assignments: $e');
    }
  }

  /// Update subject teacher assignments for a specific class and subject
  Future<void> updateSubjectTeacherAssignments(String classId, String subjectId,
      List<String> teacherIds) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'subjectId': subjectId,
        'teacherIds': teacherIds,
      });

      await webService.putData(
          'api/v1/subject-staff-assignments/class/$classId/subject/$subjectId/teachers',
          requestBody);

      if (kDebugMode) print(
          "Subject teacher assignments updated successfully for class: $classId, subject: $subjectId");
    } catch (e) {
      if (kDebugMode) print("Error updating subject teacher assignments: $e");
      throw Exception('Failed to update subject teacher assignments: $e');
    }
  }

  /// Assign staff to class
  Future<void> assignStaffToClass(String classId, String staffId) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'staffId': staffId,
      });

      await webService.postData('api/v1/staff-class-assignments', requestBody);

      if (kDebugMode) print("Staff assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning staff to class: $e");
      throw Exception('Failed to assign staff to class: $e');
    }
  }

  /// Remove staff from class
  Future<void> removeStaffFromClass(String classId, String staffId) async {
    try {
      await webService.deleteData(
          'api/v1/staff-class-assignments/class/$classId/staff/$staffId');

      if (kDebugMode) print("Staff removed from class successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing staff from class: $e");
      throw Exception('Failed to remove staff from class: $e');
    }
  }

  /// Assign staff to subject for a specific class
  Future<void> assignStaffToSubject(String classId, String subjectId,
      String staffId) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'subjectId': subjectId,
        'staffId': staffId,
      });

      await webService.postData(
          'api/v1/subject-staff-assignments', requestBody);

      if (kDebugMode) print("Staff assigned to subject successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning staff to subject: $e");
      throw Exception('Failed to assign staff to subject: $e');
    }
  }

  /// Remove staff from subject for a specific class
  Future<void> removeStaffFromSubject(String classId, String subjectId,
      String staffId) async {
    try {
      await webService.deleteData(
          'api/v1/subject-staff-assignments/class/$classId/subject/$subjectId/staff/$staffId');

      if (kDebugMode) print("Staff removed from subject successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing staff from subject: $e");
      throw Exception('Failed to remove staff from subject: $e');
    }
  }

  /// Get all subjects assigned to a specific class
  Future<List<Subject>> getSubjectsByClass(String classId) async {
    try {
      final response = await webService.fetchData(
          'api/v1/classes/$classId/subjects');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      final List<dynamic> subjectsJson = responseJson['data'];
      return subjectsJson.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print("Error fetching subjects by class: $e");
      throw Exception('Failed to fetch subjects by class: $e');
    }
  }

  /// Get class statistics (for analytics)
  Future<Map<String, dynamic>> getClassStatistics(String classId) async {
    try {
      final response = await webService.fetchData(
          'api/v1/classes/$classId/statistics');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching class statistics: $e");
      throw Exception('Failed to fetch class statistics: $e');
    }
  }

  /// Get top performing students in a class
  Future<List<dynamic>> getTopPerformers(String classId,
      {int limit = 10}) async {
    try {
      final response = await webService.fetchData(
          'api/v1/classes/$classId/top-performers?limit=$limit');
      final Map<String, dynamic> responseJson = jsonDecode(response);
      return responseJson['data'] as List<dynamic>;
    } catch (e) {
      if (kDebugMode) print("Error fetching top performers: $e");
      throw Exception('Failed to fetch top performers: $e');
    }
  }

  /// Bulk assign subjects to class
  Future<void> assignSubjectsToClass(String classId,
      List<String> subjectIds) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'subjectIds': subjectIds,
      });

      await webService.postData(
          'api/v1/classes/$classId/subjects', requestBody);

      if (kDebugMode) print("Subjects assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning subjects to class: $e");
      throw Exception('Failed to assign subjects to class: $e');
    }
  }

  /// Remove subjects from class
  Future<void> removeSubjectsFromClass(String classId,
      List<String> subjectIds) async {
    try {
      final requestBody = jsonEncode({
        'subjectIds': subjectIds,
      });

      await webService.deleteData(
          'api/v1/classes/$classId/subjects');

      if (kDebugMode) print("Subjects removed from class successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing subjects from class: $e");
      throw Exception('Failed to remove subjects from class: $e');
    }
  }
}