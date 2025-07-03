import 'dart:convert';
import 'package:sms/utils/constants.dart';
import '../models/student_dashboard_model.dart';
import '../services/web_service.dart';

class StudentDashboardRepository {
  final WebService webService;

  StudentDashboardRepository({required this.webService});

  Future<StudentDashboardModel> fetchDashboardData(String id) async {
    try {
      final response = await webService.fetchData('${ApiEndpoints.studentDashboard}/$id');

      // Parse JSON response
      final jsonData = jsonDecode(response);

      // Check if the response has the expected structure
      if (jsonData is Map<String, dynamic>) {
        // Check if response has success flag
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return StudentDashboardModel.fromJson(jsonData);
        } else {
          // Handle case where success is false
          final message = jsonData['message'] ?? 'Unknown error occurred';
          throw Exception('API Error: $message');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } on FormatException catch (e) {
      throw Exception('Failed to parse response: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<StudentDashboardModel> refreshDashboardData(String id) async {
    // For refresh, we can use the same fetch method
    // but you might want to add cache-busting parameters or different logic
    return await fetchDashboardData(id);
  }
}