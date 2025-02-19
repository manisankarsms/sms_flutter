class Class {
  final String id;
  final String name;
  final String? staff; // Change instructor to match 'staff' from API

  Class({required this.id, required this.name, this.staff});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'].toString(), // Convert int to String
      name: json['name'] ?? 'Unknown', // Provide a default value
      staff: json['staff']?.toString(), // Change from 'instructor' to 'staff'
    );
  }
}
