import 'package:equatable/equatable.dart';
import 'package:sms/models/staff_subject_assignment.dart';
import '../../models/subject.dart';
import '../../models/user.dart';

abstract class ClassDetailsState {}

class ClassDetailsInitial extends ClassDetailsState {}

class ClassDetailsLoading extends ClassDetailsState {}

class ClassDetailsError extends ClassDetailsState {
  final String error;
  ClassDetailsError(this.error);
}

// Updated to handle single teacher
class ClassTeacherLoaded extends ClassDetailsState {
  final User? teacher; // Single teacher, can be null
  ClassTeacherLoaded(this.teacher);
}

class StaffListLoaded extends ClassDetailsState {
  final List<User> staffList;
  final User? currentTeacher; // Single current teacher
  StaffListLoaded(this.staffList, this.currentTeacher);
}

class TeacherAssignmentSuccess extends ClassDetailsState {
  final String message;
  TeacherAssignmentSuccess(this.message);
}

// Subject-related states
class ClassSubjectsLoaded extends ClassDetailsState {
  final List<Subject> subjects;
  ClassSubjectsLoaded(this.subjects);
}

class AvailableSubjectsLoaded extends ClassDetailsState {
  final List<Subject> availableSubjects;
  AvailableSubjectsLoaded(this.availableSubjects);
}

class SubjectAssignmentSuccess extends ClassDetailsState {
  final String message;
  SubjectAssignmentSuccess(this.message);
}

class SubjectStaffAssignmentSuccess extends ClassDetailsState {
  final String message;
  SubjectStaffAssignmentSuccess(this.message);
}

class StaffSubjectsLoaded extends ClassDetailsState {
  final List<StaffSubjectAssignment> subjects;
  StaffSubjectsLoaded(this.subjects);
}