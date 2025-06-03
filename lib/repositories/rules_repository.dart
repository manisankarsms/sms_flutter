import 'dart:convert';
import '../models/rule.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class RulesRepository {
  final WebService webService;
  List<Rule> _cachedRules = [];

  RulesRepository({required this.webService});

  Future<List<String>> fetchRules() async {
    try {
      final response = await webService.fetchData(ApiEndpoints.rules);
      final Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData['success'] == true) {
        final List<dynamic> rulesJson = responseData['data'] ?? [];
        _cachedRules = rulesJson.map((json) => Rule.fromJson(json)).toList();

        // Return only the rule text for backward compatibility with your current implementation
        return _cachedRules.map((rule) => rule.rule).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      throw Exception('Failed to fetch rules: $e');
    }
  }

  Future<String> addRule(String rule) async {
    try {
      final requestBody = jsonEncode({
        'rule': rule,
      });

      final response = await webService.postData(
        ApiEndpoints.rules,
        requestBody,
      );
      final Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData['success'] == true) {
        return responseData['message'] ?? 'Rule added successfully';
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add rule');
      }
    } catch (e) {
      throw Exception('Failed to add rule: $e');
    }
  }

  Future<String> updateRule(int index, String rule) async {
    try {
      // Get the rule ID from cached rules using the index
      if (index >= _cachedRules.length) {
        throw Exception('Rule index out of bounds');
      }

      final ruleId = _cachedRules[index].id;
      final requestBody = jsonEncode({
        'rule': rule,
      });

      final response = await webService.putData(
        '${ApiEndpoints.rules}/$ruleId',
        requestBody,
      );
      final Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData['success'] == true) {
        return responseData['message'] ?? 'Rule updated successfully';
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update rule');
      }
    } catch (e) {
      throw Exception('Failed to update rule: $e');
    }
  }

  Future<String> deleteRule(int index) async {
    try {
      // Get the rule ID from cached rules using the index
      if (index >= _cachedRules.length) {
        throw Exception('Rule index out of bounds');
      }

      final ruleId = _cachedRules[index].id;
      final response = await webService.deleteData('${ApiEndpoints.rules}/$ruleId');
      final Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData['success'] == true) {
        return responseData['message'] ?? 'Rule deleted successfully';
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete rule');
      }
    } catch (e) {
      throw Exception('Failed to delete rule: $e');
    }
  }
}