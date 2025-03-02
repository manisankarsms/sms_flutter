import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/models/staff.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

class StaffRepository {
  final WebService webService;

  StaffRepository({required this.webService});

  Future<List<Staff>> fetchStaff() async {
    if (kDebugMode) {
      print("fetchStaff() called");
    } // Debugging

    try {
      final response = await webService.fetchData(ApiEndpoints.adminStaffs);
      if (kDebugMode) {
        print("API Response: $response");
      } // Debugging
      final List<dynamic> staffJson = jsonDecode(response);
      return staffJson.map((json) => Staff.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching staff: $e");
      } // Debugging
      throw Exception('Failed to fetch staff: $e');
    }

}

  Future<void> addStaff(Staff staff) async {
    await webService.postData('admin/staff', jsonEncode(staff.toJson()));
  }

  Future<void> deleteStaff(String staffId) async {
    await webService.postData('admin/staff/delete', jsonEncode({'staffId': staffId}));
  }
}