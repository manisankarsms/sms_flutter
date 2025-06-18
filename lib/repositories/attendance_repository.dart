
import 'dart:convert';

import 'package:intl/intl.dart';

import '../models/attendance.dart';
import '../services/web_service.dart'; // Import your WebService class

class AttendanceRepository {
  final WebService webService;

  AttendanceRepository({required this.webService});

  Future<List<Attendance>> fetchAttendance(String studentId) async {
    try {
      // Get today's date
      final DateTime today = DateTime.now();

      // Calculate the first day of two months ago
      final DateTime startDate = DateTime(today.year, today.month - 1, 1);

      // Format dates as 'yyyy-MM-dd'
      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(today);

      // Construct URL with dynamic date range and studentId
      final String url =
          'attendance/student/$studentId/range?startDate=$formattedStartDate&endDate=$formattedEndDate';

      // Make the GET request
      final String responseString = await webService.fetchData(url);
      final Map<String, dynamic> responseData = jsonDecode(responseString);

      // Check and parse response
      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> attendanceJsonList = responseData['data'];

        return attendanceJsonList
            .map((json) => Attendance.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      throw Exception('Failed to fetch attendance');
    }
  }

}
