import 'package:equatable/equatable.dart';
import 'package:sms/models/staff.dart';
import 'package:sms/models/student.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String userType;
  final List<String> permissions; // e.g., ["dashboard", "staff", "library"]
  final Student? studentData; // Nullable for student-specific fields
  final Staff? staffData; // Nullable for staff-specific fields

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    required this.permissions,
    this.studentData,
    this.staffData,
  });

  /// **Factory method to parse JSON**
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      userType: json['userType'],
      permissions: List<String>.from(json['permissions'] ?? []),
      studentData: json['userType'] == 'student' ? Student.fromJson(json['studentData']) : null,
      staffData: json['userType'] == 'staff' ? Staff.fromJson(json['staffData']) : null,
    );
  }

  /// **Convert User to JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'permissions':permissions,
      'studentData': studentData?.toJson(),
      'staffData': staffData?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, email, displayName, userType, studentData, staffData];
}
