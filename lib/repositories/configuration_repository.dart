import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/models/configuration.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

class ConfigurationRepository {
  final WebService webService;

  ConfigurationRepository({required this.webService});

  // Fetch Configuration from the backend
  Future<Configuration?> fetchConfiguration() async {
    try {
      final responseString = await webService.fetchData(ApiEndpoints.configuration);
      final Map<String, dynamic> response = jsonDecode(responseString);

      // Handle API response for missing configuration
      if (response['data'] == null) {
        return null; // Configuration not found
      }

      // Successfully fetched configuration
      return Configuration.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching configuration: $e");
      }
      return null; // Return null on error (indicating failure)
    }
  }

  // Update the configuration
  Future<bool> updateConfiguration(Configuration config) async {
    try {
      final responseString = await webService.putData(
        ApiEndpoints.configuration,
        jsonEncode(config.toJson()),
      );

      final Map<String, dynamic> response = jsonDecode(responseString);

      // Check for success or failure in the API response
      if (response['status'] == 'success') {
        return true; // Successfully updated
      } else {
        return false; // Failed to update
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating configuration: $e");
      }
      return false; // Return false on error
    }
  }

  // Uncommented version of the logo upload method (if required in the future)
  /*Future<String?> uploadLogo(String base64Image) async {
    try {
      final responseString = await webService.postData(
        ApiEndpoints.uploadLogo,
        jsonEncode({"file": base64Image}),
      );

      final Map<String, dynamic> response = jsonDecode(responseString);

      // Return the logo URL if uploaded successfully
      if (response['status'] == 'success' && response['logoUrl'] != null) {
        return response['logoUrl'];
      }
      return null; // If no logo URL found or failed
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading logo: $e");
      }
      return null; // Return null on error
    }
  }*/
}
