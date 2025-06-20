import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/models/staff.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

import '../models/user.dart';

class StaffRepository {
  final WebService webService;

  StaffRepository({required this.webService});

  /// Fetches the list of staff members
  Future<List<User>> fetchStaff() async {
    if (kDebugMode) print("Fetching staff list...");

    try {
      final response = await webService.fetchData(ApiEndpoints.staffUsers);
      if (kDebugMode) print("API Response: $response");

      final Map<String, dynamic> responseJson = jsonDecode(response); // Parse JSON here
      final List<dynamic> classesJson = responseJson['data'];
      return classesJson.map((json) => User.fromJson(json)).toList();

      /*final Map<String, dynamic> responseJson = jsonDecode(response); // Parse JSON here
      final List<dynamic> staffJson = jsonDecode(responseJson['data']);
      return staffJson.map((json) => User.fromJson(json)).toList();*/
    } catch (e) {
      if (kDebugMode) print("Error fetching staff: $e");
      throw Exception('Failed to fetch staff: $e');
    }
  }

  // Submit new staff registration with minimal data
  Future<Map<String, dynamic>> submitStaffRegistration(Map<String, dynamic> formData) async {
    try {
      // Validate data before submission
      if (!validateStaffData(formData)) {
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
        'role': formData['role'] ?? 'STAFF',
        'firstName': formData['firstName'],
        'lastName': formData['lastName'],
      });

      if (kDebugMode) {
        print('Submitting staff registration: $requestBody');
      }

      // Submit to API
      final response = await webService.postData(
        ApiEndpoints.staffRegistration,
        requestBody,
      );

      // Parse response
      final responseData = jsonDecode(response);

      if (kDebugMode) {
        print('Staff registration response: $responseData');
      }

      // Check if registration was successful
      if (responseData['success'] == true || responseData['status'] == 'success') {
        return {
          'success': true,
          'message': 'Staff registered successfully!',
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
        print('Staff registration error: ${error.toString()}');
      }

      // Handle specific error messages
      String errorMessage = 'Failed to register staff';

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

// Validate staff data before submission
  bool validateStaffData(Map<String, dynamic> formData) {
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

  /// Deletes a staff member by ID
  Future<bool> deleteStaff(String staffId) async {
    try {
      final response = await webService.postData(
        ApiEndpoints.staffDelete,
        jsonEncode({'staffId': staffId}),
      );

      final responseData = jsonDecode(response);
      if (kDebugMode) print("Delete staff response: $responseData");

      return responseData['success'] == true;
    } catch (error) {
      if (kDebugMode) print("Error deleting staff: $error");
      throw Exception('Failed to delete staff: ${error.toString()}');
    }
  }

  /// Helper function for formatting addresses
  String _formatAddress(Map<String, dynamic> address) {
    final parts = [
      address['line1'],
      address['line2'],
      address['city'],
      address['state'],
      address['pincode'],
    ];
    return parts.where((part) => part != null && part.toString().isNotEmpty).join(', ');
  }
}
