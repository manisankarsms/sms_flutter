import 'dart:convert';
import 'package:http/http.dart' as http;

class WebService {
  final String baseUrl;

  WebService({required this.baseUrl});

  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

// You can add more methods here for different types of HTTP requests (GET, PUT, DELETE, etc.)
}
