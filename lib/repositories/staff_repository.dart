import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/models/staff.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

class StaffRepository {
  final WebService webService;

  StaffRepository({required this.webService});

  /// Fetches the list of staff members
  Future<List<Staff>> fetchStaff() async {
    if (kDebugMode) print("Fetching staff list...");

    try {
      final response = await webService.fetchData(ApiEndpoints.adminStaffs);
      if (kDebugMode) print("API Response: $response");

      final List<dynamic> staffJson = jsonDecode(response);
      return staffJson.map((json) => Staff.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print("Error fetching staff: $e");
      throw Exception('Failed to fetch staff: $e');
    }
  }

  /// Registers a new staff member
  Future<bool> registerStaff(Map<String, dynamic> formData) async {
    try {
      final personalDetails = formData['personalDetails'];
      final professionalDetails = formData['professionalDetails'];
      final contactDetails = formData['contactDetails'];

      // Construct the staff object
      final Staff staff = Staff(
        id: '', // Assigned by the server
        name: "${personalDetails['firstName']} ${personalDetails['lastName']}",
        role: professionalDetails['designation'] ?? 'Unknown',
        department: professionalDetails['department'] ?? 'General',
        phoneNumber: contactDetails['primaryMobile'] ?? '',
        email: contactDetails['primaryEmail'] ?? '',
        active: true, // Default to active
      );

      // Prepare API request body
      final requestBody = jsonEncode({
        'staff': staff.toJson(),
        'additionalDetails': {
          'aadhaar': personalDetails['aadhaarNumber'] ?? '',
          'nationality': personalDetails['nationality'] ?? '',
          'experience': professionalDetails['totalExperience'] ?? '0',
          'employmentType': professionalDetails['employmentType'] ?? 'Full-Time',
        },
        'documentsUploaded': personalDetails['documentsUploaded'] ?? [],
      });

      // Submit to API
      final response = await webService.postData(ApiEndpoints.staffRegistration, requestBody);

      // Parse API response
      final responseData = jsonDecode(response);
      if (kDebugMode) print("Staff registration response: $responseData");

      return responseData['success'] == true;
    } catch (error) {
      if (kDebugMode) print("Failed to register staff: $error");
      throw Exception('Failed to register staff: ${error.toString()}');
    }
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
