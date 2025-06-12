import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';

import '../models/class.dart';
import '../models/staff_subject_assignment.dart';
import '../models/subject.dart';
import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart';

class ClassDetailsRepository {
  final WebService webService;

  ClassDetailsRepository({required this.webService});

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

  /// Get class teacher assignment - Returns single User or null
  Future<User?> getClassTeacherAssignments(String classId) async {
    try {
      final response = await webService.fetchData(
          'staff-class-assignments/class/$classId/staff');

      if (kDebugMode) print("Fetching class teacher assignment for class: $classId");

      final Map<String, dynamic> responseJson = jsonDecode(response);

      // Check if response is successful and has data
      if (responseJson['success'] == true &&
          responseJson.containsKey('data') &&
          responseJson['data'] != null) {

        final List<dynamic> assignmentsData = responseJson['data'];

        // Check if there are any assignments
        if (assignmentsData.isNotEmpty) {
          final assignmentData = assignmentsData[0]; // Get first assignment

          // Create User object from the assignment data
          final teacher = User(
            id: assignmentData['staffId'],
            firstName: assignmentData['staffName'] ?? '',
            lastName: '', // staffName seems to contain the full name
            email: assignmentData['staffEmail'],
            // Add other required User fields with default values or from assignmentData
            role: assignmentData['role'] ?? 'TEACHER', permissions: [],
          );

          if (kDebugMode) print("Found class teacher: ${teacher.firstName} for class $classId");
          return teacher;
        } else {
          if (kDebugMode) print("No class teacher assigned to class $classId");
          return null;
        }
      } else {
        if (kDebugMode) print("No class teacher assigned or unsuccessful response");
        return null;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching class teacher assignment: $e");
      // Return null instead of throwing exception to handle "no teacher assigned" case
      return null;
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

  /// Assign staff to class
  Future<void> assignStaffToClass(String classId, String staffId) async {
    try {
      final requestBody = jsonEncode({
        'classId': classId,
        'staffId': staffId,
      });

      await webService.postData('staff-class-assignments', requestBody);

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
          'staff-class-assignments/class/$classId/staff');

      if (kDebugMode) print("Staff removed from class successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing staff from class: $e");
      throw Exception('Failed to remove staff from class: $e');
    }
  }

  // ============================================================================
  // SUBJECT-RELATED METHODS
  // ============================================================================

  /// Fetch all available subjects
  Future<List<Subject>> fetchSubjects() async {
    try {
      if (kDebugMode) print("Fetching all subjects...");

      final responseString = await webService.fetchData(ApiEndpoints.subjects);
      final Map<String, dynamic> response = jsonDecode(responseString);
      final List<dynamic> subjectsJson = response['data'];

      if (kDebugMode) print("Found ${subjectsJson.length} total subjects");

      return subjectsJson.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching subjects: $e");
      }
      throw Exception('Failed to fetch subjects: $e');
    }
  }

  /// Get subjects assigned to a specific class
  Future<List<Subject>> getClassSubjects(String classId) async {
    try {
      if (kDebugMode) print("Fetching subjects for class: $classId");

      final response = await webService.fetchData(
          'class-subjects/class/$classId/subjects');

      final Map<String, dynamic> responseJson = jsonDecode(response);

      if (responseJson['success'] == true &&
          responseJson.containsKey('data') &&
          responseJson['data'] != null) {

        final List<dynamic> subjectsData = responseJson['data'];

        if (kDebugMode) print("Found ${subjectsData.length} subjects for class $classId");

        return subjectsData.map((subjectData) {
          return Subject(
            id: subjectData['subjectId'],
            name: subjectData['subjectName'],
            code: subjectData['subjectCode'],
            classSubjectId: subjectData['id']
            // Add other Subject fields as needed based on your Subject model
          );
        }).toList();
      } else {
        if (kDebugMode) print("No subjects assigned to class $classId");
        return [];
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching class subjects: $e");
      // Return empty list instead of throwing exception to handle gracefully
      return [];
    }
  }

  /// Get available subjects that are not yet assigned to a class
  Future<List<Subject>> getAvailableSubjectsForClass(String classId) async {
    try {
      if (kDebugMode) print("Fetching available subjects for class: $classId");

      // Get all subjects
      final allSubjects = await fetchSubjects();

      // Get subjects already assigned to this class
      final assignedSubjects = await getClassSubjects(classId);
      final assignedSubjectIds = assignedSubjects.map((s) => s.id).toSet();

      // Filter out already assigned subjects
      final availableSubjects = allSubjects
          .where((subject) => !assignedSubjectIds.contains(subject.id))
          .toList();

      if (kDebugMode) print("Found ${availableSubjects.length} available subjects for class $classId");

      return availableSubjects;
    } catch (e) {
      if (kDebugMode) print("Error fetching available subjects: $e");
      throw Exception('Failed to fetch available subjects: $e');
    }
  }

  /// Assign a subject to a class
  Future<void> assignSubjectToClass(String classId, String subjectId) async {
    try {
      if (kDebugMode) print("Assigning subject $subjectId to class $classId");

      final requestBody = jsonEncode({
        'classId': classId,
        'subjectId': subjectId,
      });

      await webService.postData('class-subjects', requestBody);

      if (kDebugMode) print("Subject assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning subject to class: $e");
      throw Exception('Failed to assign subject to class: $e');
    }
  }

  /// Assign a subject to a class
  Future<void> bulkAssignSubjectToClass(String classId, List<String> subjectId) async {
    try {
      if (kDebugMode) print("Assigning subject $subjectId to class $classId");

      final requestBody = jsonEncode({
        'classId': classId,
        'subjectIds': subjectId,
      });

      await webService.postData('class-subjects/bulk', requestBody);

      if (kDebugMode) print("Subject assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning subject to class: $e");
      throw Exception('Failed to assign subject to class: $e');
    }
  }

  /// Remove a subject from a class
  Future<void> removeSubjectFromClass(String? subjectId) async {
    try {

      await webService.deleteData(
          'class-subjects/$subjectId');

      if (kDebugMode) print("Subject removed from class successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing subject from class: $e");
      throw Exception('Failed to remove subject from class: $e');
    }
  }

  /// Update subject assignments for a class (bulk operation)
  Future<void> updateClassSubjectAssignments(String classId, List<String> subjectIds) async {
    try {
      if (kDebugMode) print("Updating subject assignments for class $classId");

      final requestBody = jsonEncode({
        'classId': classId,
        'subjectIds': subjectIds,
      });

      await webService.putData(
          '/class-subject-assignments/class/$classId/subjects',
          requestBody);

      if (kDebugMode) print("Class subject assignments updated successfully");
    } catch (e) {
      if (kDebugMode) print("Error updating class subject assignments: $e");
      throw Exception('Failed to update class subject assignments: $e');
    }
  }

  Future<List<StaffSubjectAssignment>> getStaffSubjectAssignments(String classId) async {
    try {
      if (kDebugMode) print("Fetching staff-subject assignments for class: $classId");

      final response = await webService.fetchData('staff-subject-assignments/class/$classId/staff');
      final Map<String, dynamic> responseJson = jsonDecode(response);

      if (responseJson['success'] == true &&
          responseJson.containsKey('data') &&
          responseJson['data'] != null) {

        final List<dynamic> assignmentData = responseJson['data'];

        return assignmentData
            .map((data) => StaffSubjectAssignment.fromJson(data))
            .toList();
      } else {
        if (kDebugMode) print("No staff-subject assignments found for class $classId");
        return [];
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching assignments: $e");
      return [];
    }
  }


  /// Assign a subject to a class
  Future<void> assignStaffToSubject(String classId, String subjectId, String? classSubjectId) async {
    try {
      if (kDebugMode) print("Assigning subject $subjectId to class $classId");

      final requestBody = jsonEncode({
        'classId': classId,
        'staffId': subjectId,
        'classSubjectId':classSubjectId
      });

      await webService.postData('staff-subject-assignments', requestBody);

      if (kDebugMode) print("Subject assigned to class successfully");
    } catch (e) {
      if (kDebugMode) print("Error assigning subject to class: $e");
      throw Exception('Failed to assign subject to class: $e');
    }
  }

  /// Remove a subject from a class
  Future<void> removeStaffFromSubject(String? subjectId) async {
    try {

      await webService.deleteData(
          'staff-subject-assignments/$subjectId');

      if (kDebugMode) print("Subject removed from class successfully");
    } catch (e) {
      if (kDebugMode) print("Error removing subject from class: $e");
      throw Exception('Failed to remove subject from class: $e');
    }
  }
}