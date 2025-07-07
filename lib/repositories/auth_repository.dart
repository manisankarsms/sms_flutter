import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/utils/constants.dart';
import '../models/client.dart';
import '../models/user.dart';
import '../services/fcm_service.dart';
import '../services/request.dart';
import '../services/web_service.dart';

class AuthRepository {
  final WebService webService;

  // Session keys
  static const String _keyUserData = 'user_data';
  static const String _keyLoginTime = 'login_time';
  static const String _keySessionDuration = 'session_duration';
  static const String _keyActiveUser = 'active_user';
  static const String _keyAllUsers = 'all_users';
  static const String _keyAutoLoginEnabled = 'auto_login_enabled';

  // Default session duration (7 days in milliseconds)
  static const int defaultSessionDuration = 7 * 24 * 60 * 60 * 1000;

  AuthRepository({required this.webService});

  Future<List<User>> signInWithMobileAndPassword(String mobile, String password, String userType) async {
    String? fcmToken = await FCMService.getToken();
    try {
      String request = await frameLoginRequestFCM(mobile, password, fcmToken);
      if (kDebugMode) {
        print("POST Data: $request");
      }

      final data = await webService.postData(ApiEndpoints.loginWithFCM, request);

      if (kDebugMode) {
        print("Response: $data");
      }

      final Map<String, dynamic> response = jsonDecode(data.toString());

      if (response['success'] == true) {
        final List<dynamic> userList = response['data']['user'];
        final users = userList.map((user) => User.fromJson(user)).toList();

        await _saveLoginSession(users);
        return users;
      } else {
        throw Exception(response['message'] ?? "Unknown error");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error signing in: $error");
      }
      rethrow;
    }
  }

  Future<void> getOtp(String email) async {
    try {
      String request = frameGetOtpRequest(email);
      if (kDebugMode) {
        print(request);
      }
      await webService.postData(ApiEndpoints.loginGetOtp, request);
    } catch (error) {
      if (kDebugMode) {
        print("Error getting OTP: $error");
      }
      rethrow;
    }
  }

  Future<List<User>> sendOtp(String email, String otp) async {
    try {
      String request = frameVerifyOtpRequest(email, otp);
      if (kDebugMode) {
        print(request);
      }

      final data = await webService.postData(ApiEndpoints.loginVerifyOtp, request);
      final Map<String, dynamic> jsonResponse = jsonDecode(data.toString());
      final List<dynamic> usersJson = jsonResponse['data']['user'];

      final users = usersJson.map((user) => User.fromJson(user)).toList();

      // Save login session after successful OTP verification
      await _saveLoginSession(users);

      return users;
    } catch (error) {
      if (kDebugMode) {
        print("Error verifying OTP: $error");
      }
      rethrow;
    }
  }

  // Save login session data
  Future<void> _saveLoginSession(List<User> users, {int? customDurationMs}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionDuration = customDurationMs ?? defaultSessionDuration;

    // Convert users to JSON
    final usersJson = users.map((user) => user.toJson()).toList();

    await prefs.setString(_keyAllUsers, jsonEncode(usersJson));
    await prefs.setInt(_keyLoginTime, currentTime);
    await prefs.setInt(_keySessionDuration, sessionDuration);
    await prefs.setBool(_keyAutoLoginEnabled, true);

    if (kDebugMode) {
      print("Session saved. Expires: ${DateTime.fromMillisecondsSinceEpoch(currentTime + sessionDuration)}");
    }
  }

  // Save active user selection
  Future<void> saveActiveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveUser, jsonEncode(user.toJson()));
  }

  // Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final autoLoginEnabled = prefs.getBool(_keyAutoLoginEnabled) ?? false;
      if (!autoLoginEnabled) return false;

      final loginTime = prefs.getInt(_keyLoginTime);
      final sessionDuration = prefs.getInt(_keySessionDuration);

      if (loginTime == null || sessionDuration == null) return false;

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final expiryTime = loginTime + sessionDuration;

      final isValid = currentTime < expiryTime;

      if (kDebugMode) {
        print("Session check - Current: ${DateTime.fromMillisecondsSinceEpoch(currentTime)}");
        print("Session expires: ${DateTime.fromMillisecondsSinceEpoch(expiryTime)}");
        print("Session valid: $isValid");
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking session validity: $e");
      }
      return false;
    }
  }

  // Get stored session data
  Future<SessionData?> getStoredSession() async {
    try {
      if (!await isSessionValid()) {
        await clearSession(); // Clear expired session
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyAllUsers);
      final activeUserJson = prefs.getString(_keyActiveUser);

      if (usersJson == null) return null;

      final List<dynamic> usersData = jsonDecode(usersJson);
      final users = usersData.map((json) => User.fromJson(json)).toList();

      User? activeUser;
      if (activeUserJson != null) {
        activeUser = User.fromJson(jsonDecode(activeUserJson));
      }

      return SessionData(users: users, activeUser: activeUser);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting stored session: $e");
      }
      return null;
    }
  }

  // Set session duration (in days)
  Future<void> setSessionDuration(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final durationMs = days * 24 * 60 * 60 * 1000;
    await prefs.setInt(_keySessionDuration, durationMs);

    if (kDebugMode) {
      print("Session duration set to $days days");
    }
  }

  // Get remaining session time in hours
  Future<int> getRemainingSessionHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt(_keyLoginTime);
      final sessionDuration = prefs.getInt(_keySessionDuration);

      if (loginTime == null || sessionDuration == null) return 0;

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final expiryTime = loginTime + sessionDuration;
      final remainingMs = expiryTime - currentTime;

      return remainingMs > 0 ? (remainingMs / (1000 * 60 * 60)).ceil() : 0;
    } catch (e) {
      return 0;
    }
  }

  // Enable/disable auto-login
  Future<void> setAutoLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLoginEnabled, enabled);
  }

  // Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLoginEnabled) ?? false;
  }

  // Extend current session
  Future<void> extendSession({int? additionalDays}) async {
    if (!await isSessionValid()) return;

    final prefs = await SharedPreferences.getInstance();
    final currentSessionDuration = prefs.getInt(_keySessionDuration) ?? defaultSessionDuration;
    final extension = (additionalDays ?? 7) * 24 * 60 * 60 * 1000;
    final newDuration = currentSessionDuration + extension;

    await prefs.setInt(_keySessionDuration, newDuration);

    if (kDebugMode) {
      print("Session extended by ${additionalDays ?? 7} days");
    }
  }

  Future<void> logout() async {
    try {
      // Optional: Call server logout endpoint
      // await webService.postData('logout', '{}');

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyLoginTime);
    await prefs.remove(_keySessionDuration);
    await prefs.remove(_keyActiveUser);
    await prefs.remove(_keyAllUsers);
    await prefs.remove(_keyAutoLoginEnabled);

    if (kDebugMode) {
      print("Session cleared");
    }
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
}

// Helper class to hold session data
class SessionData {
  final List<User> users;
  final User? activeUser;

  SessionData({required this.users, this.activeUser});
}