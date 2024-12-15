import '../../models/class.dart';

abstract class ClassesEvent {}

class LoadClasses extends ClassesEvent {}

class AddClass extends ClassesEvent {
  final Class newClass;

  AddClass(this.newClass);
}

class DeleteClass extends ClassesEvent {
  final String classId;

  DeleteClass(this.classId);
}

class SearchClasses extends ClassesEvent {
  final String query;

  SearchClasses(this.query);
}
