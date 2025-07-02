import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sms/models/profile.dart';
import 'package:sms/services/web_service.dart';
import 'package:sms/utils/constants.dart';

class ProfileRepository {
  final WebService webService;

  ProfileRepository({required this.webService});

  // Fetch Profile
  Future<Profile?> fetchProfile(String userId) async {
    try {
      final responseString = await webService.fetchData('${ApiEndpoints.userProfile}/$userId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['data'] == null) {
        return null;
      }

      return Profile.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
      return null;
    }
  }

  // Update Profile
  Future<bool> updateProfile(Profile profile, String userId) async {
    try {
      final responseString = await webService.putData(
        '${ApiEndpoints.userProfile}/$userId',
        jsonEncode(profile.toJson()),
      );

      final Map<String, dynamic> response = jsonDecode(responseString);

      return response['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile: $e");
      }
      return false;
    }
  }

  // Upload Avatar
  Future<String?> uploadAvatar(String userId, File avatarFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.baseUrl}/${ApiEndpoints.uploadLogo}'),
      );

      request.fields['userId'] = userId;

      final fileName = avatarFile.path.split('/').last;
      final fileSize = await avatarFile.length();

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          avatarFile.path,
          filename: fileName,
        ),
      );

      if (kDebugMode) {
        print('=== UPLOAD AVATAR REQUEST ===');
        print('File: $fileName, Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseString);
        if (responseData['success'] == true && responseData['fileUrl'] != null) {
          return responseData['fileUrl'];
        } else {
          throw Exception(responseData['message'] ?? 'Avatar upload failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Avatar upload failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading avatar: $e");
      }
      return null;
    }
  }

  // Update Profile with optional avatar upload
  Future<Profile?> updateProfileWithAvatar({
    required Profile profile,
    required String userId,
    File? avatarFile,
    XFile? avatarXFile,
  }) async {
    try {
      String? avatarUrl;

      // Upload avatar if file is provided
      if (avatarFile != null || avatarXFile != null) {
        final file = avatarFile ?? File(avatarXFile!.path);
        avatarUrl = await uploadAvatar(userId, file);
      }

      final updatedProfile = profile.copyWith(
        avatarUrl: avatarUrl ?? profile.avatarUrl,
      );

      final success = await updateProfile(updatedProfile, userId);

      if (success) {
        return updatedProfile;
      } else {
        throw Exception('Failed to update profile with avatar');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile with avatar: $e");
      }
      return null;
    }
  }
}
