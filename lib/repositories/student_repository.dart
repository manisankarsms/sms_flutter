import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../services/request.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentRepository {
  final WebService webService;

  StudentRepository({required this.webService});

  // Submit new student registration with minimal data
  Future<Map<String, dynamic>> submitStudentRegistration(Map<String, dynamic> formData) async {
    try {
      // Validate data before submission
      if (!validateStudentData(formData)) {
        return {
          'success': false,
          'message': 'Invalid form data. Please check all required fields.',
        };
      }

      // Prepare request body matching your minimal JSON structure
      final requestBody = jsonEncode({
        'email': formData['email'],
        'mobileNumber': formData['mobileNumber'],
        'password': formData['password'],
        'role': formData['role'] ?? 'STUDENT',
        'firstName': formData['firstName'],
        'lastName': formData['lastName'],
      });

      if (kDebugMode) {
        print('Submitting student registration: $requestBody');
      }

      // Submit to API
      final response = await webService.postData(
        ApiEndpoints.studentAdmission,
        requestBody,
      );

      // Parse response
      final responseData = jsonDecode(response);

      if (kDebugMode) {
        print('Registration response: $responseData');
      }

      // Check if registration was successful
      if (responseData['success'] == true || responseData['status'] == 'success') {
        return {
          'success': true,
          'message': 'Student registered successfully!',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'data': responseData,
        };
      }

    } catch (error) {
      if (kDebugMode) {
        print('Student registration error: ${error.toString()}');
      }

      // Handle specific error messages
      String errorMessage = 'Failed to register student';

      if (error.toString().contains('Email already exists')) {
        errorMessage = 'This email address is already registered. Please use a different email.';
      } else if (error.toString().contains('Mobile number already exists')) {
        errorMessage = 'This mobile number is already registered. Please use a different number.';
      } else if (error.toString().contains('Network error') || error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (error.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (error.toString().contains('FormatException')) {
        errorMessage = 'Invalid server response. Please try again.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': error.toString(),
      };
    }
  }

  // Validate student data before submission
  bool validateStudentData(Map<String, dynamic> formData) {
    final requiredFields = ['email', 'mobileNumber', 'password', 'firstName', 'lastName'];

    for (String field in requiredFields) {
      if (formData[field] == null || formData[field].toString().trim().isEmpty) {
        if (kDebugMode) {
          print('Validation failed: $field is required');
        }
        return false;
      }
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(formData['email'].toString().trim())) {
      if (kDebugMode) {
        print('Validation failed: Invalid email format');
      }
      return false;
    }

    // Mobile number validation (assuming 10 digits)
    final mobileNumber = formData['mobileNumber'].toString().trim();
    if (mobileNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobileNumber)) {
      if (kDebugMode) {
        print('Validation failed: Mobile number must be 10 digits');
      }
      return false;
    }

    // Password validation
    if (formData['password'].toString().length < 6) {
      if (kDebugMode) {
        print('Validation failed: Password must be at least 6 characters');
      }
      return false;
    }

    return true;
  }

  // Check if email already exists
  /*Future<bool> checkEmailExists(String email) async {
    try {
      final response = await webService.getData('${ApiEndpoints.checkEmail}?email=$email');
      final responseData = jsonDecode(response);

      return responseData['exists'] == true;
    } catch (error) {
      if (kDebugMode) {
        print('Check email error: ${error.toString()}');
      }
      return false; // Assume email doesn't exist if check fails
    }
  }


  // Login method for student authentication
  Future<Map<String, dynamic>?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'role': 'STUDENT',
      });

      final response = await webService.postData(
        ApiEndpoints.studentLogin,
        requestBody,
      );

      final responseData = jsonDecode(response);

      if (responseData['success'] == true || responseData['status'] == 'success') {
        return responseData;
      }

      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Student login error: ${error.toString()}');
      }
      rethrow;
    }
  }

  // Get student profile by ID
  Future<Student?> getStudentProfile(String studentId) async {
    try {
      final response = await webService.getData('${ApiEndpoints.studentProfile}/$studentId');
      final responseData = jsonDecode(response);

      if (responseData['success'] == true && responseData['data'] != null) {
        return Student.fromJson(responseData['data']);
      }

      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Get student profile error: ${error.toString()}');
      }
      rethrow;
    }
  }

  // Update student profile
  Future<bool> updateStudentProfile(String studentId, Map<String, dynamic> updateData) async {
    try {
      final requestBody = jsonEncode(updateData);

      final response = await webService.putData(
        '${ApiEndpoints.studentProfile}/$studentId',
        requestBody,
      );

      final responseData = jsonDecode(response);
      return responseData['success'] == true || responseData['status'] == 'success';

    } catch (error) {
      if (kDebugMode) {
        print('Update student profile error: ${error.toString()}');
      }
      rethrow;
    }
  }

  // Get all students (for admin use)
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await webService.getData(ApiEndpoints.allStudents);
      final responseData = jsonDecode(response);

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> studentsJson = responseData['data'];
        return studentsJson.map((json) => Student.fromJson(json)).toList();
      }

      return [];
    } catch (error) {
      if (kDebugMode) {
        print('Get all students error: ${error.toString()}');
      }
      rethrow;
    }
  }

  // Delete student account
  Future<bool> deleteStudent(String studentId) async {
    try {
      final response = await webService.deleteData('${ApiEndpoints.studentProfile}/$studentId');
      final responseData = jsonDecode(response);

      return responseData['success'] == true || responseData['status'] == 'success';
    } catch (error) {
      if (kDebugMode) {
        print('Delete student error: ${error.toString()}');
      }
      rethrow;
    }
  }*/
}