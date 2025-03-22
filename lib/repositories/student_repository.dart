import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../services/request.dart';
import '../services/web_service.dart';
import '../utils/constants.dart'; // Import your WebService class

class StudentRepository {
  final WebService webService;

  StudentRepository({required this.webService});

  // Submit new student admission
  Future<bool> submitStudentAdmission(Map<String, dynamic> formData) async {
    try {
      // Create student object from form data
      final studentDetails = formData['studentDetails'];
      final contactDetails = formData['contactDetails'];

      // Basic student object required for the API
      final Student student = Student(
        studentId: '', // Will be assigned by the server
        firstName: studentDetails['firstName'] ?? '',
        lastName: studentDetails['lastName'] ?? '',
        dateOfBirth: studentDetails['dateOfBirth'] ?? '',
        gender: studentDetails['gender'] ?? '',
        contactNumber: contactDetails['mobile']['primary'] ?? '',
        email: contactDetails['email']['primary'] ?? '',
        address: _formatAddress(contactDetails['address']),
        studentStandard: studentDetails['class'] ?? '',
      );

      // Prepare full request body with all admission details
      final requestBody = jsonEncode({
        'student': student.toJson(),
        'additionalDetails': {
          'bloodGroup': studentDetails['bloodGroup'],
          'religion': studentDetails['religion'],
          'community': studentDetails['community'],
          'motherTongue': studentDetails['motherTongue'],
          'nationality': studentDetails['nationality'],
          'aadhaar': studentDetails['aadhaar'],
          'previousSchool': studentDetails['previousSchool'],
        },
        'familyDetails': formData['familyDetails'],
        'documentsUploaded': studentDetails['documentsUploaded'],
      });

      // Submit to API
      final response = await webService.postData(ApiEndpoints.studentAdmission, requestBody);

      // Parse response
      final responseData = jsonDecode(response);
      return responseData['success'] == true;
    } catch (error) {
      throw Exception('Failed to submit student admission: ${error.toString()}');
    }
  }

  // Helper method to format address from components
  String _formatAddress(Map<String, dynamic> address) {
    final parts = [
      address['line1'],
      address['line2'],
      address['city'],
      address['state'],
      address['pincode'],
    ];

    return parts.where((part) => part != null && part.toString().isNotEmpty)
        .join(', ');
  }

// Additional student-related methods like updateStudent, deleteStudent, fetchStudents can be added here.
}
