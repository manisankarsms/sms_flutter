import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sms/models/configuration.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

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

  // Upload logo with FormData
  Future<String?> uploadLogo({
    required String userId,
    File? logoFile,
    XFile? logoXFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.baseUrl}/${ApiEndpoints.uploadLogo}'),
      );

      // Add userId to form data
      request.fields['userId'] = userId;

      String fileName = '';
      int fileSize = 0;

      // Add file to form data
      if (kIsWeb && logoXFile != null) {
        // For web platform
        final bytes = await logoXFile.readAsBytes();
        fileName = logoXFile.name;
        fileSize = bytes.length;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // field name that backend expects
            bytes,
            filename: fileName,
          ),
        );
      } else if (!kIsWeb && logoFile != null) {
        // For mobile/desktop platforms
        fileName = logoFile.path.split('/').last;
        fileSize = await logoFile.length();

        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // field name that backend expects
            logoFile.path,
            filename: fileName,
          ),
        );
      } else {
        throw Exception('No file provided for upload');
      }

      // Add headers if needed (like authorization)
      // request.headers.addAll({
      //   'Authorization': 'Bearer $token',
      // });

      // Log request details
      if (kDebugMode) {
        print('=== UPLOAD LOGO REQUEST ===');
        print('URL: ${request.url}');
        print('Method: ${request.method}');
        print('Headers: ${request.headers}');
        print('Fields: ${request.fields}');
        print('File Name: $fileName');
        print('File Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        print('Files Count: ${request.files.length}');
        print('============================');
      }

      final stopwatch = Stopwatch()..start();
      final response = await request.send();
      stopwatch.stop();

      final responseString = await response.stream.bytesToString();

      // Log response details
      if (kDebugMode) {
        print('=== UPLOAD LOGO RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Reason Phrase: ${response.reasonPhrase}');
        print('Response Headers: ${response.headers}');
        print('Content Length: ${response.contentLength ?? 'Unknown'}');
        print('Response Time: ${stopwatch.elapsedMilliseconds}ms');
        print('Response Body: $responseString');
        print('=============================');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseString);

        if (responseData['success'] == true && responseData['fileUrl'] != null) {
          String logoUrl = responseData['fileUrl'];

          if (kDebugMode) {
            print('✅ Logo upload successful: $logoUrl');
          }
          return logoUrl;
        } else {
          if (kDebugMode) {
            print('❌ Upload failed - Server response indicates failure');
          }
          throw Exception(responseData['message'] ?? 'Upload failed');
        }
      } else {
        if (kDebugMode) {
          print('❌ HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
        }
        throw Exception('HTTP ${response.statusCode}: Failed to upload logo');
      }
    } catch (e) {
      if (kDebugMode) {
        print('=== UPLOAD LOGO ERROR ===');
        print("Error uploading logo: $e");
        print('Error Type: ${e.runtimeType}');
        if (e is Exception) {
          print('Exception Details: ${e.toString()}');
        }
        print('========================');
      }
      throw Exception('Failed to upload logo: $e');
    }
  }

  // Update the configuration
  // Update the configuration
  Future<bool> updateConfiguration(Configuration config) async {
    try {
      final responseString = await webService.putData(
        ApiEndpoints.configuration,
        jsonEncode(config.toJson()),
      );

      final Map<String, dynamic> response = jsonDecode(responseString);

      // Check for success or failure in the API response
      // Changed from response['status'] to response['success']
      if (response['success'] == true) {
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

  // Combined method to upload logo and update configuration
  Future<Configuration?> updateConfigurationWithLogo({
    required Configuration config,
    required String userId,
    File? logoFile,
    XFile? logoXFile,
  }) async {
    try {
      String? logoUrl;

      // Upload logo if file is provided
      if (logoFile != null || logoXFile != null) {
        logoUrl = await uploadLogo(
          userId: userId,
          logoFile: logoFile,
          logoXFile: logoXFile,
        );
      }

      // Update configuration with new logo URL
      final updatedConfig = Configuration(
        id: config.id,
        schoolName: config.schoolName,
        logoUrl: logoUrl ?? config.logoUrl, // Use new URL or keep existing
        address: config.address,
        email: config.email,
        phoneNumber1: config.phoneNumber1,
        phoneNumber2: config.phoneNumber2,
        phoneNumber3: config.phoneNumber3,
        phoneNumber4: config.phoneNumber4,
        phoneNumber5: config.phoneNumber5,
        website: config.website,
      );

      // Save updated configuration
      final success = await updateConfiguration(updatedConfig);

      if (success) {
        return updatedConfig;
      } else {
        throw Exception('Failed to update configuration');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating configuration with logo: $e");
      }
      rethrow;
    }
  }
}