import 'dart:convert';

class Client {
  final String id;
  final String name;
  final String address;
  final String baseUrl;
  final String logoUrl;
  final Map<String, dynamic> metadata;

  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.baseUrl,
    this.logoUrl = '',
    this.metadata = const {},
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      baseUrl: json['baseUrl'] as String,
      logoUrl: json['logoUrl'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'baseUrl': baseUrl,
      'logoUrl': logoUrl,
      'metadata': metadata,
    };
  }

  // Convert a list of clients to JSON string
  static String toJsonList(List<Client> clients) {
    final List<Map<String, dynamic>> jsonList = clients.map((client) => client.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // Parse a JSON string to a list of clients
  static List<Client> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Client.fromJson(json)).toList();
  }
}