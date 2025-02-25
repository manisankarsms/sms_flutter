
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart'; // Import your WebService class

class AuthRepository {
  final WebService webService;

  AuthRepository({required this.webService});

  Future<User?> signInWithMobileAndPassword(String mobile, String password) async {
    try {
      String request = frameLoginRequest(mobile, password);
      if (kDebugMode) {
        print(request);
      }
      final data = await webService.postData('login', request);
      return User.fromJson(jsonDecode(data.toString()));
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
