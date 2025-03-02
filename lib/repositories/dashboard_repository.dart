import 'dart:convert';

import 'package:sms/utils/constants.dart';

import '../models/dashboard_model.dart';
import '../services/web_service.dart';

class DashboardRepository {
  final WebService webService;

  DashboardRepository({required this.webService});

  Future<DashboardModel> fetchDashboardData() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.adminDashboard);
      return DashboardModel.fromJson(jsonDecode(response));
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}