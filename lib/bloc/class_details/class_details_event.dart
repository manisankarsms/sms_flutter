import 'package:equatable/equatable.dart';

abstract class ClassDetailsEvent extends Equatable {
  const ClassDetailsEvent();
  @override
  List<Object?> get props => [];
}

class LoadClassTeachers extends ClassDetailsEvent {
  final String classId;

  const LoadClassTeachers(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadStaffList extends ClassDetailsEvent {}

class AssignTeacherToClass extends ClassDetailsEvent {
  final String classId;
  final String teacherId;

  const AssignTeacherToClass(this.classId, this.teacherId);

  @override
  List<Object?> get props => [classId, teacherId];
}

class UpdateClassTeachers extends ClassDetailsEvent {
  final String classId;
  final List<String> teacherIds;

  const UpdateClassTeachers(this.classId, this.teacherIds);

  @override
  List<Object?> get props => [classId, teacherIds];
}

class RemoveTeacherFromClass extends ClassDetailsEvent {
  final String classId;
  final String teacherId;

  const RemoveTeacherFromClass(this.classId, this.teacherId);

  @override
  List<Object?> get props => [classId, teacherId];
}

// Subject-related events
class LoadClassSubjects extends ClassDetailsEvent {
  final String classId;
  LoadClassSubjects(this.classId);
}

class LoadStaffSubjects extends ClassDetailsEvent {
  final String classId;
  LoadStaffSubjects(this.classId);
}

class LoadAvailableSubjects extends ClassDetailsEvent {}

class AssignSubjectToClass extends ClassDetailsEvent {
  final String classId;
  final String subjectId;

  AssignSubjectToClass(this.classId, this.subjectId);
}

class BulkAssignSubjectsToClass extends ClassDetailsEvent {
  final String classId;
  final List<String> subjectId;

  BulkAssignSubjectsToClass(this.classId, this.subjectId);
}

class RemoveSubjectFromClass extends ClassDetailsEvent {
  final String? classSubjectId;
  final String classId;

  RemoveSubjectFromClass(this.classSubjectId, this.classId);
}

class AssignStaffToSubject extends ClassDetailsEvent {
  final String classId;
  final String subjectId;
  final String? classSubjectId;

  AssignStaffToSubject(this.classId, this.subjectId, this.classSubjectId);
}

class RemoveStaffFromSubject extends ClassDetailsEvent {
  final String? staffSubjectId;
  final String classId;

  RemoveStaffFromSubject(this.staffSubjectId, this.classId);
}