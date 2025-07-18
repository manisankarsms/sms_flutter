import 'dart:convert';

class Client {
  final String id;
  final String name;
  final String schemaName;

  Client({
    required this.id,
    required this.name,
    required this.schemaName,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      schemaName: json['schemaName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'schemaName': schemaName,
    };
  }

  /// Convert a list of clients to JSON string
  static String toJsonList(List<Client> clients) {
    final List<Map<String, dynamic>> jsonList =
    clients.map((client) => client.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Parse a JSON string to a list of clients
  static List<Client> fromJsonList(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw FormatException("Expected a JSON list");
    }
    return decoded
        .map<Client>((json) => Client.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
