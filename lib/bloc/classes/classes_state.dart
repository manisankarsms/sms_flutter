import '../../models/class.dart';
import '../../models/subject.dart';
import '../../models/user.dart';

enum ClassesStatus { initial, loading, success, failure }

class ClassesState {
  final ClassesStatus status;
  final List<Class> classes;
  final List<Class> filteredClasses;
  final String searchQuery;
  final String? error;
  final String? message;

  const ClassesState({
    this.status = ClassesStatus.initial,
    this.classes = const [],
    this.filteredClasses = const [],
    this.searchQuery = '',
    this.error,
    this.message,
  });

  ClassesState copyWith({
    ClassesStatus? status,
    List<Class>? classes,
    List<Class>? filteredClasses,
    String? searchQuery,
    String? error,
    String? message,
  }) {
    return ClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      filteredClasses: filteredClasses ?? this.filteredClasses,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
      message: message,
    );
  }

  // Clear temporary messages
  ClassesState clearMessages() {
    return copyWith(
      error: null,
      message: null,
    );
  }
}

class StaffAndSubjectsLoading extends ClassesState {}

class StaffAndSubjectsLoaded extends ClassesState {
  final List<User> staff;
  final List<Subject> subjects;

  const StaffAndSubjectsLoaded({
    required this.staff,
    required this.subjects,
  });

  @override
  List<Object> get props => [staff, subjects];
}

class ClassesError extends ClassesState {
  final String errorMessage;

  const ClassesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}