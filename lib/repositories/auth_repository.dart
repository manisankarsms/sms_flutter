
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';

import '../models/client.dart';
import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart'; // Import your WebService class

class AuthRepository {
  final WebService webService;

  AuthRepository({required this.webService});

  // Future<List<User>> signInWithMobileAndPassword(String mobile, String password) async {
  //   try {
  //     String request = frameLoginRequest(mobile, password);
  //     if (kDebugMode) {
  //       print(request);
  //     }
  //     final data = await webService.postData(ApiEndpoints.login, request);
  //     final List<dynamic> jsonResponse = jsonDecode(data.toString());
  //
  //     return jsonResponse.map((user) => User.fromJson(user)).toList();
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print("Error signing in: $error");
  //     }
  //     rethrow;
  //   }
  // }

  Future<List<User>> signInWithMobileAndPassword(String mobile, String password, String userType) async {
    try {
      String request = frameLoginRequest(mobile, password);
      if (kDebugMode) {
        print(request);
      }
      final endpointMap = {
        Constants.student: ApiEndpoints.studentLogin,
        Constants.staff: ApiEndpoints.staffLogin,
        Constants.admin: ApiEndpoints.adminLogin,
      };

      final endPoint = endpointMap[userType] ?? ApiEndpoints.adminLogin;
      final data = await webService.postData(endPoint, request);
      final List<dynamic> jsonResponse = jsonDecode(data.toString());

      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } catch (error) {
      if (kDebugMode) {
        print("Error signing in: $error");
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // await webService.postData('logout', '{}'); // Adjust API endpoint if needed
      // Clear stored session data (e.g., tokens)
      await clearSession();
      if (kDebugMode) {
        print("User logged out successfully.");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error logging out: $error");
      }
    }
  }

  Future<void> clearSession() async {
    // Example: Clearing stored user session (modify as needed)
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
  }

  Future<List<Client>> fetchClients() async {
    try {
      final String responseString = await webService.fetchData('config/clients');
      if (kDebugMode) {
        print("Fetch Clients API Response: $responseString");
      }
      final Map<String, dynamic> response = jsonDecode(responseString);
      if (response['status'] != 1) {
        throw Exception(response['message'] ?? 'Failed to fetch clients');
      }
      final List<dynamic> clientsJson = response['clients'];
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching clients: $e");
      }
      throw Exception('Failed to fetch clients: $e');
    }
  }

// Additional authentication methods like signOut, signUp, resetPassword can be added here.
}
