import '../../models/class.dart';

enum ClassesStatus { initial, loading, success, failure }

class ClassesState {
  final ClassesStatus status;
  final List<Class> classes;
  final List<Class> filteredClasses;
  final String searchQuery;

  const ClassesState({
    this.status = ClassesStatus.initial,
    this.classes = const [],
    this.filteredClasses = const [],
    this.searchQuery = '',
  });

  ClassesState copyWith({
    ClassesStatus? status,
    List<Class>? classes,
    List<Class>? filteredClasses,
    String? searchQuery,
  }) {
    return ClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      filteredClasses: filteredClasses ?? this.filteredClasses,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StaffAndSubjectsLoading extends ClassesState {}

class StaffAndSubjectsLoaded extends ClassesState {
  final List<Map<String, dynamic>> staff;
  final List<Map<String, dynamic>> subjects;

  const StaffAndSubjectsLoaded({
    required this.staff,
    required this.subjects
  });

  @override
  List<Object> get props => [staff, subjects];
}

class ClassesError extends ClassesState {
  final String message;

  const ClassesError(this.message);

  @override
  List<Object> get props => [message];
}