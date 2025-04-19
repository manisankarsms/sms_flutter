import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/permissions.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class PermissionRepository {
  final WebService webService;

  PermissionRepository({required this.webService});

  // Fetch available features
  Future<List<PermissionDefinition>> fetchDefinitions() async {
    try {
      final responseString = await webService.fetchData(ApiEndpoints.features);
      final List<dynamic> listJson = jsonDecode(responseString) as List<dynamic>;
      return listJson.map((j) => PermissionDefinition.fromJson(j)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching features: $e');
      throw Exception('Failed to fetch features: $e');
    }
  }

  // Fetch all staff and their permissions
  Future<List<Staff>> fetchAllStaff() async {
    try {
      // get definitions first
      final defs = await fetchDefinitions();
      final allKeys = defs.map((d) => d.key).toList();

      final responseString = await webService.fetchData(ApiEndpoints.staff);
      final List<dynamic> listJson = jsonDecode(responseString)['staff'] as List<dynamic>;
      return listJson.map((j) => Staff.fromJson(j, allKeys)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching staff: $e');
      throw Exception('Failed to fetch staff: $e');
    }
  }

  // Update permissions for a single staff
  Future<bool> updatePermissions(String staffId, List<String> permissions) async {
    try {
      final body = jsonEncode({ 'permissions': permissions });
      final responseString = await webService.postData(
        '${ApiEndpoints.staff}/$staffId/permissions',
        body,
      );
      return responseString.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('Error updating permissions: $e');
      return false;
    }
  }
}