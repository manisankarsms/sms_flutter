import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/dashboard_model.dart';
import '../services/web_service.dart';

class DashboardRepository {
  final WebService webService;

  DashboardRepository({required this.webService});

  Future<DashboardModel> fetchDashboardData() async {
    try {
      final Map<String, dynamic> response = await webService.fetchData('admin/dashboard');
      return DashboardModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}