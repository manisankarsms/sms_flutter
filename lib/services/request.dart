import 'dart:convert';

String frameLoginRequest(String mobile, String password) {
  Map<String, dynamic> jsonMap = {
    'username': mobile,
    'password': password,
  };
  return jsonEncode(jsonMap);
}