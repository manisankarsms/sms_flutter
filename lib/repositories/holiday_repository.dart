import 'dart:convert';
import 'package:sms/models/holiday.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

// holiday_repository.dart
import 'dart:convert';
import '../models/holiday.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class HolidayRepository {
  final WebService webService;

  HolidayRepository({required this.webService});

  Future<List<Holiday>> fetchHolidays() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.adminHolidays);
      final Map<String, dynamic> responseData = jsonDecode(response);
      final List<dynamic> holidaysJson = responseData['data'] ?? [];
      return holidaysJson.map((json) => Holiday.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch holidays: $e');
    }
  }

  Future<String> addHoliday(Holiday holiday) async {
    try {
      final response = await webService.postData(
        ApiEndpoints.adminHolidays,
        jsonEncode(holiday.toJson()),
      );
      final Map<String, dynamic> responseData = jsonDecode(response);
      return responseData['message'] ?? 'Holiday added successfully';
    } catch (e) {
      throw Exception('Failed to add holiday: $e');
    }
  }

  Future<String> updateHoliday(Holiday holiday) async {
    try {
      final response = await webService.putData(
        '${ApiEndpoints.adminHolidays}/${holiday.id}',
        jsonEncode(holiday.toJson()),
      );
      final Map<String, dynamic> responseData = jsonDecode(response);
      return responseData['message'] ?? 'Holiday updated successfully';
    } catch (e) {
      throw Exception('Failed to update holiday: $e');
    }
  }

  Future<String> deleteHoliday(int id) async {
    try {
      final response = await webService.deleteData('${ApiEndpoints.adminHolidays}/$id');
      final Map<String, dynamic> responseData = jsonDecode(response);
      return responseData['message'] ?? 'Holiday deleted successfully';
    } catch (e) {
      throw Exception('Failed to delete holiday: $e');
    }
  }
}
