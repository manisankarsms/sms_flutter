// student_state.dart
import '../../models/user.dart';
import '../../models/class.dart';

abstract class UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<User> users;
  final List<Class> classes;

  UsersLoaded(this.users, {this.classes = const []});
}

class ClassesLoaded extends UserState {
  final List<Class> classes;
  final List<User> users;

  ClassesLoaded(this.classes, {this.users = const []});
}

class UsersAndClassesLoaded extends UserState {
  final List<User> users;
  final List<Class> classes;

  UsersAndClassesLoaded(this.users, this.classes);
}

class UserOperationInProgress extends UserState {
  final List<User> users;
  final List<Class> classes;
  final String message;

  UserOperationInProgress(this.users, this.message, {this.classes = const []});
}

class UserOperationSuccess extends UserState {
  final List<User> users;
  final List<Class> classes;
  final String message;

  UserOperationSuccess(this.users, this.message, {this.classes = const []});
}

class UserOperationFailure extends UserState {
  final String error;
  final List<User> users;
  final List<Class> classes;

  UserOperationFailure(this.error, this.users, {this.classes = const []});
}