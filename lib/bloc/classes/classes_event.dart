import 'package:equatable/equatable.dart';

import '../../models/class.dart';

abstract class ClassesEvent extends Equatable {
  const ClassesEvent();

  @override
  List<Object?> get props => [];
}

class LoadClasses extends ClassesEvent {
  const LoadClasses();
}

class AddClass extends ClassesEvent {
  final Class newClass;

  const AddClass(this.newClass);

  @override
  List<Object?> get props => [newClass];
}

class UpdateClass extends ClassesEvent {
  final Class updatedClass;

  const UpdateClass(this.updatedClass);

  @override
  List<Object?> get props => [updatedClass];
}

class DeleteClass extends ClassesEvent {
  final String classId;

  const DeleteClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class SearchClasses extends ClassesEvent {
  final String query;

  const SearchClasses(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchStaffAndSubjects extends ClassesEvent {
  const FetchStaffAndSubjects();
}

class ClearMessages extends ClassesEvent {
  const ClearMessages();
}
