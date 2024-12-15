import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/request.dart';
import '../services/web_service.dart';

class ProfileRepository {
  final WebService webService;

  ProfileRepository({required this.webService});

  Future<Map<String, dynamic>?> fetchProfileData(String mobile, String userId) async {
    try {
      String request = frameProfileRequest(mobile, userId); // Assuming this function frames the request payload
      if (kDebugMode) {
        print(request);
      }
      final data = await webService.postData('getProfile', request); // Assuming 'getProfile' is the endpoint

      // Parse the response data
      Map<String, dynamic>? profileData = data as Map<String, dynamic>?;

      return profileData;
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching profile data: $error");
      }
      rethrow; // Rethrow the error for higher-level error handling
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      final data = profile.toJson().toString(); // Assuming you have a toJson method in Profile model
      final response = await webService.postData('profileUpdate', data); // Assume 'profileUpdate' is the endpoint
      if (kDebugMode) {
        print('Update response: $response');
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error updating profile: $error");
      }
      rethrow; // Rethrow the error for higher-level error handling
    }
  }
}
