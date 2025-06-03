import 'dart:convert';

import 'package:sms/models/student.dart';

String frameLoginRequest(String mobile, String password) {
  Map<String, dynamic> jsonMap = {
    'mobileNumber': mobile,
    'password': password,
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
    'contactNumber': student.contactNumber,
    'email': student.email,
    'address': student.address,
    'studentStandard': student.studentStandard,
  };
  return jsonEncode(jsonMap);
}
