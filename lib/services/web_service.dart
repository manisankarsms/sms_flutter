import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../cryptography/aes.dart';
import '../utils/constants.dart'; // Add this import

class WebService {
  final String baseUrl;

  WebService({required this.baseUrl});

  // Helper method to build headers with optional tenantId
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // Add tenantId to headers if it's not null or empty
    if (Constants.tenantId.isNotEmpty) {
      headers['X-Tenant'] = Constants.tenantId;
    }

    return headers;
  }

  Future<String> postData(String endpoint, String data) async {
    try {
      // Remove the encryption part that was causing issues
      if (kDebugMode) {
        print('POST URL: $baseUrl/$endpoint');
        print('POST Data: $data');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _buildHeaders(),
        body: data, // Send data directly, not double-encoded
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        // Handle error responses properly
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in postData: $e");
      }
      rethrow; // Rethrow the original exception
    }
  }

  Future<String> fetchData(String endpoint) async {
    try {
      if (kDebugMode) {
        print('GET URL: $baseUrl/$endpoint');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _buildHeaders(),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Handle error responses properly
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in getData: $e");
      }
      rethrow;
    }
  }

  Future<String> putData(String endpoint, String data) async {
    try {
      if (kDebugMode) {
        print('PUT URL: $baseUrl/$endpoint');
        print('PUT Data: $data');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _buildHeaders(),
        body: data,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in putData: $e");
      }
      rethrow;
    }
  }

  Future<String> deleteData(String endpoint) async {
    try {
      if (kDebugMode) {
        print('DELETE URL: $baseUrl/$endpoint');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _buildHeaders(),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.statusCode == 204 ? '' : response.body;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            throw Exception(errorData['error']['message'] ?? 'Server error');
          } else {
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in deleteData: $e");
      }
      rethrow;
    }
  }
}