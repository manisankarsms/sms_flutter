import 'package:equatable/equatable.dart';

class Staff extends Equatable {
  final String id;
  final String name;
  final String role;
  final String department;
  final String phoneNumber;
  final String email;
  final bool active;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phoneNumber,
    required this.email,
    required this.active,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['staffId'],
      name: json['name'],
      role: json['role'],
      department: json['department'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      active: json['active'],
    );
  }

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

  @override
  List<Object?> get props => [id, name, role, department, phoneNumber, email, active];
}
