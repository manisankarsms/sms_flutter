import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sms/models/student.dart';
import '../models/class.dart';

String frameLoginRequest(String mobile, String password) {
  Map<String, dynamic> jsonMap = {
    'mobileNumber': mobile,
    'password': password,
  };
  return jsonEncode(jsonMap);
}

Future<String> frameLoginRequestFCM(String mobile, String password, String? fcmToken) async {
  final deviceId = await getDeviceId();
  final platform = getPlatform();

  Map<String, dynamic> jsonMap = {
    'mobileNumber': mobile,
    'password': password,
    'fcmToken': fcmToken,
    'platform': platform,
    'deviceId': deviceId
  };
  return jsonEncode(jsonMap);
}

String frameGetOtpRequest(String email) {
  Map<String, dynamic> jsonMap = {
    'email': email
  };
  return jsonEncode(jsonMap);
}

String frameVerifyOtpRequest(String email, String otpCode) {
  Map<String, dynamic> jsonMap = {
    'email': email,
    'otpCode': otpCode,
  };
  return jsonEncode(jsonMap);
}

String frameProfileRequest(String mobile, String userId) {
  Map<String, dynamic> jsonMap = {
    'mobile': mobile,
    'userId': userId,
  };
  return jsonEncode(jsonMap);
}

String frameAddStudentRequest(Student student) {
  Map<String, dynamic> jsonMap = {
    'firstName': student.firstName,
    'lastName': student.lastName,
    'dateOfBirth': student.dateOfBirth,
    'gender': student.gender,
    'contactNumber': student.mobileNumber,
    'email': student.email,
    'address': student.address,
    'studentStandard': student.studentStandard,
  };
  return jsonEncode(jsonMap);
}

String frameAddClassRequest(Class myClass) {
  Map<String, dynamic> jsonMap = {
    'className': myClass.className,
    'sectionName': myClass.sectionName
  };
  return jsonEncode(jsonMap);
}

Future<String> getDeviceId() async {
  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      // For web platform, use browser info as device ID
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      // Create a unique identifier from browser info
      final browserIdentifier = '${webBrowserInfo.browserName.name}_${webBrowserInfo.userAgent?.hashCode ?? 'unknown'}';
      return browserIdentifier;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown_ios";
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.systemGUID ?? "unknown_macos";
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.machineId ?? "unknown_linux";
    }
    return "unsupported_platform";
  } catch (e) {
    if (kDebugMode) {
      print('Error getting device ID: $e');
    }
    return "error_getting_device_id";
  }
}

String getPlatform() {
  try {
    if (kIsWeb) {
      return "web";
    } else if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    } else if (Platform.isMacOS) {
      return "macos";
    } else if (Platform.isWindows) {
      return "windows";
    } else if (Platform.isLinux) {
      return "linux";
    }
    return "unknown";
  } catch (e) {
    if (kDebugMode) {
      print('Error getting platform: $e');
    }
    return "error_getting_platform";
  }
}