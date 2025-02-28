import 'dart:convert';
import 'package:http/http.dart' as http;

class WebService {
  final String baseUrl;

  WebService({required this.baseUrl});

  Future<String> postData(String endpoint, String data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: data,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<String> fetchData(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return response.body; // Return raw JSON string instead of decoding
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // New method for PUT requests
  Future<String> putData(String endpoint, String data) async {
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