import 'dart:convert';

import 'package:sms/models/student.dart';

String frameLoginRequest(String mobile, String password) {
  Map<String, dynamic> jsonMap = {
    'username': mobile,
    'password': password,
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
