import 'dart:convert';

import '../models/complaint.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class ComplaintRepository {
  final WebService webService;

  ComplaintRepository({required this.webService});

  // Fetch complaints from API
  Future<List<Complaint>> fetchComplaints() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.complaints);
      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> complaintsJson = responseData['data'] ?? [];

      return complaintsJson.map((json) {
        // Map API response fields to your model fields
        final mappedJson = {
          'id': json['id'],
          'author': json['author'],
          'title': json['title'],           // API uses 'title', model uses 'subject'
          'content': json['content'],     // API uses 'content', model uses 'description'
          'category': json['category'],
          'status': json['status'],
          'createdAt': json['createdAt'],
          'isAnonymous': json['isAnonymous'] ?? false,
          'comments': json['comments'] ?? [],
        };
        return Complaint.fromJson(mappedJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch complaints: ${error.toString()}');
    }
  }

  // Fetch complaints by user ID (for user-specific complaints)
  Future<List<Complaint>> fetchComplaintsByUserId(String userId) async {
    try {
      final response = await webService.fetchData('${ApiEndpoints.complaints}/author/$userId');
      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> complaintsJson = responseData['data'] ?? [];

      return complaintsJson.map((json) {
        // Map API response fields to your model fields
        final mappedJson = {
          'id': json['id'],
          'author': json['author'],
          'title': json['title'],           // API uses 'title', model uses 'subject'
          'content': json['content'],     // API uses 'content', model uses 'description'
          'category': json['category'],
          'status': json['status'],
          'createdAt': json['createdAt'],
          'isAnonymous': json['isAnonymous'] ?? false,
          'comments': json['comments'] ?? [],
        };
        return Complaint.fromJson(mappedJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch user complaints: ${error.toString()}');
    }
  }


  // Add a new complaint
  Future<void> addComplaint(Complaint complaint) async {
    try {
      final requestBody = jsonEncode(complaint.toJson());
      await webService.postData(ApiEndpoints.complaints, requestBody);
    } catch (error) {
      throw Exception('Failed to add complaint: ${error.toString()}');
    }
  }

  // Update complaint status (separate endpoint)
  Future<void> updateComplaintStatus(String complaintId, String newStatus, String comment) async {
    try {
      final body = jsonEncode({
        'status': newStatus,
        'comment': comment,
        'commentedBy': 'Admin' ?? '',
        'commentedAt': DateTime.now().toString() ?? '',
      });      await webService.putData('${ApiEndpoints.complaints}/$complaintId/status', body);
    } catch (error) {
      throw Exception('Failed to update complaint status: ${error.toString()}');
    }
  }

  // Add comment to complaint
  Future<void> addCommentToComplaint({
    required String complaintId,
    required String comment,
    required String commentedBy,
  }) async {
    try {
      final requestBody = jsonEncode({
        'comment': comment,
        'commentedBy': commentedBy,
        'commentedAt': DateTime.now().toString() ?? '',
      });

      await webService.postData('${ApiEndpoints.complaints}/$complaintId/comments', requestBody);
    } catch (error) {
      throw Exception('Failed to add comment: ${error.toString()}');
    }
  }
}
