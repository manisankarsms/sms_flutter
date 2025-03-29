import 'package:equatable/equatable.dart';

class Staff extends Equatable {
  final String id;
  final String name;
  final String role;
  final String department;
  final String phoneNumber;
  final String email;
  final bool active;

  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phoneNumber,
    required this.email,
    required this.active,
  });

  // Factory method to create a Staff object from JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['staffId'] ?? '', // Default to empty string if null
      name: json['name'] ?? '',
      role: json['role'] ?? 'Unknown', // Default role if missing
      department: json['department'] ?? 'General',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      active: json['active'] ?? false, // Default to inactive if null
    );
  }

  // Convert Staff object to JSON
  Map<String, dynamic> toJson() {
    return {
      'staffId': id,
      'name': name,
      'role': role,
      'department': department,
      'phoneNumber': phoneNumber,
      'email': email,
      'active': active,
    };
  }

  // Allows cloning with optional modifications
  Staff copyWith({
    String? id,
    String? name,
    String? role,
    String? department,
    String? phoneNumber,
    String? email,
    bool? active,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [id, name, role, department, phoneNumber, email, active];
}

