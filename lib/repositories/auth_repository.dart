
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sms/utils/constants.dart';

import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart'; // Import your WebService class

class AuthRepository {
  final WebService webService;

  AuthRepository({required this.webService});

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

// Additional authentication methods like signOut, signUp, resetPassword can be added here.
}
