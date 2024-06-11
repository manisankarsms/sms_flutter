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

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'), // Construct the full URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Specify the content type if needed
      },
    );

    if (response.statusCode == 200) {
      // If successful, decode the response body (JSON) and return it
      return jsonDecode(response.body);
    } else {
      // If unsuccessful, throw an exception with an error message
      throw Exception('Failed to fetch data');
    }
  }

// You can add more methods here for different types of HTTP requests (GET, PUT, DELETE, etc.)
}
