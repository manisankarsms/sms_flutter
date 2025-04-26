import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../cryptography/aes.dart';

class WebService {
  final String baseUrl;

  WebService({required this.baseUrl});

  Future<String> postData(String endpoint, String data) async {
    try {
    String aesKey = AESUtil.generateKey();
    final encryptedBody = AESUtil.encrypt(jsonEncode(data), aesKey);
    if (kDebugMode) {
      print('$baseUrl/$endpoint');
      print(data);
      print(encryptedBody);
      print(aesKey);
    }
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'mode': 'no-cors',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: data,
    );
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  } catch(e){
      if (kDebugMode) {
        print("Error in postData: $e");
      }
      throw Exception('Network error: $e');
    }
  }

  Future<String> fetchData(String endpoint) async {
    if (kDebugMode) {
      print('$baseUrl/$endpoint');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200)
    {
      if (kDebugMode) {
        print(response.body);
      }
      return response.body; // Return raw JSON string instead of decoding
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      throw Exception('Failed to fetch data');
    }
  }

  // New method for PUT requests
  Future<String> putData(String endpoint, String data) async {
    if (kDebugMode) {
      print('$baseUrl/$endpoint');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: data,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to update data');
    }
  }

  // New method for DELETE requests
  Future<String> deleteData(String endpoint) async {
    if (kDebugMode) {
      print('$baseUrl/$endpoint');
    }
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.statusCode == 204 ? '' : response.body;
    } else {
      throw Exception('Failed to delete data');
    }
  }
}