import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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
  final deviceId = await getDeviceId();  // ✅ await here
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

String frameAddStudentRequest(
    Student student) {
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
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id ?? "unknown";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? "unknown";
  }
  return "unsupported_platform";
}

String getPlatform() {
  if (Platform.isAndroid) return "android";
  if (Platform.isIOS) return "ios";
  return "unknown";
}
