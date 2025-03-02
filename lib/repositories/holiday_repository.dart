import 'dart:convert';
import 'package:sms/models/holiday.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

class HolidayRepository {
  final WebService webService;

  HolidayRepository({required this.webService});

  Future<List<Holiday>> fetchHolidays() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.adminHolidays);
      final Map<String, dynamic> responseData = jsonDecode(response); // Parse JSON here
      final List<dynamic> holidaysJson = responseData['data'] ?? [];
      return holidaysJson.map((json) => Holiday.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch holidays: $e');
    }
  }
}