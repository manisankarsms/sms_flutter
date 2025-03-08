import 'dart:convert';

import '../models/complaint.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class ComplaintRepository {
  final WebService webService;

  ComplaintRepository({required this.webService});

  // Fetch complaints
  Future<List<Complaint>> fetchComplaints() async {
    print("Fetch called");
    try {
      final response = await webService.fetchData(ApiEndpoints.complaints);
      print(response);
      final List<dynamic> complaintsJson = jsonDecode(response);
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch complaints: ${error.toString()}');
    }
  }

  // Add a new complaint
  Future<void> addComplaint(Complaint complaint) async {
    try {
      final requestBody = jsonEncode(complaint.toJson());
      await webService.postData(ApiEndpoints.addComplaint, requestBody);
    } catch (error) {
      throw Exception('Failed to add complaint: ${error.toString()}');
    }
  }

  // Update complaint status with a comment
  Future<void> updateComplaintStatus(String id, String status, String comment) async {
    try {
      final requestBody = jsonEncode({'id': id, 'status': status, 'comment': comment});
      await webService.postData(ApiEndpoints.updateComplaintStatus, requestBody);
    } catch (error) {
      throw Exception('Failed to update complaint status: ${error.toString()}');
    }
  }

}
