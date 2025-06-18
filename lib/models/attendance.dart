import 'package:flutter/material.dart';

class Attendance {
  final String id;
  final String studentId;
  final String classId;
  final String date; // Date as string from API (e.g., "2025-06-17")
  final String status; // "PRESENT", "ABSENT", "LEAVE", etc.
  final String studentName;
  final String studentEmail;
  final String className;
  final String sectionName;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    required this.studentName,
    required this.studentEmail,
    required this.className,
    required this.sectionName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      studentName: json['studentName'] as String,
      studentEmail: json['studentEmail'] as String,
      className: json['className'] as String,
      sectionName: json['sectionName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'date': date,
      'status': status,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'className': className,
      'sectionName': sectionName,
    };
  }

  // Helper method to get DateTime from string date
  DateTime get dateTime => DateTime.parse(date);

  // Helper method to get formatted date string
  String get formattedDate {
    final dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Helper method to get status color
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LEAVE':
      case 'LATE':
        return Colors.orange;
      case 'EXCUSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData get statusIcon {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Icons.check_circle;
      case 'ABSENT':
        return Icons.cancel;
      case 'LEAVE':
      case 'LATE':
        return Icons.event_busy;
      case 'EXCUSED':
        return Icons.event_available;
      default:
        return Icons.help_outline;
    }
  }

  @override
  String toString() {
    return 'Attendance{id: $id, studentName: $studentName, date: $date, status: $status, className: $className, sectionName: $sectionName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Attendance &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}