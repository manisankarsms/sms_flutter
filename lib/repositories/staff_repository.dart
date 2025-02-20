import 'dart:convert';
import 'package:sms/models/staff.dart';
import 'package:sms/services/web_service.dart';

class StaffRepository {
  final WebService webService;

  StaffRepository({required this.webService});

  Future<List<Staff>> fetchStaff() async {
    print("fetchStaff() called"); // Debugging

    try {
      final response = await webService.fetchData('admin/staffs');
      print("API Response: $response"); // Debugging
      final List<dynamic> staffJson = jsonDecode(response);
      return staffJson.map((json) => Staff.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching staff: $e"); // Debugging
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